#!/usr/bin/env bash
set -euo pipefail

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
  command -v apt-get >/dev/null || { echo 'Non-Debian Linux: install dependencies from README, then use --no-system.' >&2; exit 1; }
  sudo_cmd=()
  if ((EUID != 0)); then sudo_cmd=(sudo); fi
  "${sudo_cmd[@]}" apt-get update
  packages=(ca-certificates git curl tar gzip python3 ripgrep wl-clipboard xclip)
  if ((tools)); then packages+=(python3-venv ruby ruby-dev build-essential libyaml-dev libffi-dev zlib1g-dev pkg-config); fi
  "${sudo_cmd[@]}" apt-get install -y "${packages[@]}"
fi
for executable in git curl tar python3 sha256sum; do
  command -v "$executable" >/dev/null || { echo "Missing dependency: $executable" >&2; exit 1; }
done
prefix=${XDG_DATA_HOME:-"$HOME/.local/share"}/veridis-neovim
config_base=${XDG_CONFIG_HOME:-"$HOME/.config"}
config=$config_base/veridis-nvim
mkdir -p "$prefix/releases" "$config_base" "$HOME/.local/bin"
scratch=$(mktemp -d "$prefix/install.XXXXXXXX")
trap 'rm -rf -- "$scratch"' EXIT
if [[ -z $source_dir ]]; then
  git clone --quiet --depth 1 --branch "$ref" https://github.com/VeridisEst/dotfiles.git "$scratch/source"
  source_dir=$scratch/source
fi
source_dir=$(cd "$source_dir" && pwd)
[[ -f $source_dir/nvim/plugins.json && -d $source_dir/document-template ]] || { echo 'Incomplete source checkout.' >&2; exit 1; }
version=v0.12.6
release_id=$(cat "$source_dir/nvim/plugins.json" "$source_dir/tools/python-requirements.txt" "$source_dir/tools/Gemfile" | sha256sum | cut -c1-16)
release=$prefix/releases/$version-$release_id-tools$tools
if [[ ! -f $release/READY ]]; then
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
  if ((tools)); then
    python3 -m venv "$release/python"
    "$release/python/bin/pip" install --disable-pip-version-check -r "$source_dir/tools/python-requirements.txt"
    "$release/python/bin/pip" freeze > "$release/python-installed.txt"
    mkdir -p "$release/gems" "$release/ruby" "$release/ruby-bin"
    GEM_HOME="$release/gems" GEM_PATH="$release/gems" gem install bundler --version 2.5.23 --no-document --install-dir "$release/gems" --bindir "$release/gems/bin"
    cp "$source_dir/tools/Gemfile" "$release/ruby/Gemfile"
    GEM_HOME="$release/gems" GEM_PATH="$release/gems" BUNDLE_GEMFILE="$release/ruby/Gemfile" BUNDLE_PATH="$release/gems" "$release/gems/bin/bundle" _2.5.23_ install
    python3 "$source_dir/scripts/write-ruby-launchers.py" "$release"
  fi
  touch "$release/READY"
fi
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
if ! grep -q '^# veridis-neovim PATH$' "$HOME/.profile" 2>/dev/null; then
  printf '\n# veridis-neovim PATH\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$HOME/.profile"
fi
echo "Installed $version; documents: $documents_dir"
echo 'Start now: ~/.local/bin/nvim (or open a new login shell and use nvim).'
echo 'No documents were downloaded, uploaded or synchronized.'
if [[ $documents_dir != "$HOME/documenten" ]]; then
  printf 'Set NVIM_DOCUMENTS to your custom directory: %s\n' "$documents_dir"
fi
