#!/usr/bin/env bash
set -Eeuo pipefail
phase=voorbereiding
scratch=
log_dir=${XDG_STATE_HOME:-"$HOME/.local/state"}/veridis-neovim
mkdir -p "$log_dir"
log_file=$log_dir/install-$(date +%Y%m%d-%H%M%S).$$.log
exec > >(tee -a "$log_file") 2>&1
trap 'code=$?; echo "INSTALLATIE MISLUKT: stap=$phase, foutcode=$code, regel=$LINENO" >&2; echo "Log: $log_file" >&2; exit "$code"' ERR
trap 'if [[ -n $scratch ]]; then rm -rf -- "$scratch"; fi' EXIT

ref=main
source_dir=
documents_dir=${NVIM_DOCUMENTS:-"$HOME/documenten"}
system_deps=1
tools=1
while (($#)); do
  case "$1" in
    --ref) ref=${2:?missing ref}; shift 2 ;;
    --source) source_dir=${2:?missing source}; shift 2 ;;
    --documents-dir) documents_dir=${2:?missing directory}; shift 2 ;;
    --no-system) system_deps=0; shift ;;
    --no-tools) tools=0; shift ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done
[[ $(uname -s) == Linux ]] || { echo 'This installer targets Linux and WSL.' >&2; exit 1; }
[[ $HOME == /* && $HOME != / ]] || { echo 'Invalid HOME' >&2; exit 1; }
case $(uname -m) in
  x86_64) arch=x86_64; digest=474430d53e6264f6d6dd18db42d6dc9df3a1b56ca9e88a325bbf860e1a811d87 ;;
  aarch64|arm64) arch=arm64; digest=8f1f64a0bdb97247034038c3823c6cbad5bdf9ecd5751b85494b71c3ee04c815 ;;
  *) echo 'Supported architectures: x86_64 and arm64.' >&2; exit 1 ;;
esac
if ((system_deps)); then
  phase=basispakketten
  echo '[1/4] Alleen de basisbenodigdheden voor Neovim installeren.'
  command -v apt-get >/dev/null || { echo 'Non-Debian Linux: install dependencies from README, then use --no-system.' >&2; exit 1; }
  sudo_cmd=()
  if ((EUID != 0)); then sudo_cmd=(sudo); fi
  "${sudo_cmd[@]}" apt-get update
  packages=(ca-certificates git curl tar gzip python3 ripgrep)
  if ! grep -qi microsoft /proc/sys/kernel/osrelease; then
    if [[ -n ${WAYLAND_DISPLAY:-} ]]; then packages+=(wl-clipboard); fi
    if [[ -n ${DISPLAY:-} ]]; then packages+=(xclip); fi
  fi
  "${sudo_cmd[@]}" apt-get install -y --no-install-recommends "${packages[@]}"
fi
for executable in git curl tar python3 sha256sum; do
  command -v "$executable" >/dev/null || { echo "Missing dependency: $executable" >&2; exit 1; }
done
prefix=${XDG_DATA_HOME:-"$HOME/.local/share"}/veridis-neovim
config_base=${XDG_CONFIG_HOME:-"$HOME/.config"}
config=$config_base/veridis-nvim
mkdir -p "$prefix/releases" "$config_base" "$HOME/.local/bin"
scratch=$(mktemp -d "$prefix/install.XXXXXXXX")
phase=bronbestanden
if [[ -z $source_dir ]]; then
  git clone --quiet --depth 1 --branch "$ref" https://github.com/VeridisEst/dotfiles.git "$scratch/source"
  source_dir=$scratch/source
fi
source_dir=$(cd "$source_dir" && pwd)
[[ -f $source_dir/nvim/plugins.json && -d $source_dir/document-template ]] || { echo 'Incomplete source checkout.' >&2; exit 1; }
version=v0.12.6
release_id=$(cat "$source_dir/nvim/plugins.json" "$source_dir/tools/python-requirements.txt" "$source_dir/tools/Gemfile" | sha256sum | cut -c1-16)
release=$prefix/releases/$version-$release_id-phased
phase=neovim-en-plugins
echo '[2/4] Neovim, vaste pluginversies en spelling installeren.'
if [[ ! -f $release/CORE_READY ]]; then
  stage=$scratch/release
  mkdir -p "$stage/site/spell"
  curl --fail --location --retry 3 "https://github.com/neovim/neovim/releases/download/$version/nvim-linux-$arch.tar.gz" -o "$scratch/nvim.tar.gz"
  printf '%s  %s\n' "$digest" "$scratch/nvim.tar.gz" | sha256sum --check -
  tar -xzf "$scratch/nvim.tar.gz" -C "$stage"
  mv "$stage/nvim-linux-$arch" "$stage/neovim"
  "$stage/neovim/bin/nvim" --version | head -n 3
  python3 "$source_dir/scripts/install-plugins.py" "$source_dir/nvim/plugins.json" "$stage/site"
  for lang in en nl; do
    curl --fail --location --retry 3 "https://ftp.nluug.nl/pub/vim/runtime/spell/$lang.utf-8.spl" -o "$stage/site/spell/$lang.utf-8.spl"
  done
  (cd "$stage/site/spell"; sha256sum --check "$source_dir/tools/spell.sha256")
  # Virtualenv scripts embed absolute paths: move before installing tools.
  [[ ! -e $release ]] || mv "$release" "$release.incomplete.$(date +%s).$$"
  mv "$stage" "$release"
  touch "$release/CORE_READY"
fi
phase=editor-activeren
echo '[3/4] Editor testen, startcommando activeren en documentstructuur aanvullen.'
mkdir -p "$scratch/config/veridis-nvim"
cp -a "$source_dir/nvim/." "$scratch/config/veridis-nvim/"
export NVIM_APPNAME=veridis-nvim VERIDIS_RELEASE="$release"
export PATH="$release/python/bin:$release/ruby-bin:$PATH"
XDG_CONFIG_HOME="$scratch/config" NVIM_DOCUMENTS="$scratch/test-docs" "$release/neovim/bin/nvim" --headless -i NONE "+luafile $source_dir/tests/smoke.lua"
backup_suffix=$(date +%Y%m%d-%H%M%S).$$
if [[ -e $config || -L $config ]]; then
  mv "$config" "$config.backup.$backup_suffix"
  echo "Previous config: $config.backup.$backup_suffix"
fi
mv "$scratch/config/veridis-nvim" "$config"
python3 "$source_dir/scripts/seed-documents.py" "$source_dir/document-template" "$documents_dir"
python3 "$source_dir/scripts/write-launcher.py" "$release" "$HOME/.local/bin/nvim" "$tools"
for shell_file in "$HOME/.profile" "$HOME/.bashrc"; do
  if ! grep -q '^# veridis-neovim PATH$' "$shell_file" 2>/dev/null; then
    printf '\n# veridis-neovim PATH\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$shell_file"
  fi
done
echo "EDITOR KLAAR: $version; documenten: $documents_dir"
echo 'Je kunt nu al starten: ~/.local/bin/nvim'
echo 'Voor nvim in deze bestaande terminal: export PATH="$HOME/.local/bin:$PATH"; hash -r'
if ((tools)); then
  phase=python-ruby-codehulp
  echo '[4/4] Aanvullende Python/Ruby-codehulp. Dit is het grootste deel van de installatie.'
  echo 'Als deze stap mislukt blijft de editor hierboven bruikbaar.'
  bash "$source_dir/scripts/install-tools.sh" "$release" "$source_dir" "$system_deps"
else
  echo '[4/4] Codehulp overgeslagen (--no-tools).'
fi
echo "INSTALLATIE GESLAAGD. Log: $log_file"
echo 'Er zijn geen persoonlijke documenten opgehaald, geupload of gesynchroniseerd.'
if [[ $documents_dir != "$HOME/documenten" ]]; then
  printf 'Set NVIM_DOCUMENTS to your custom directory: %s\n' "$documents_dir"
fi
