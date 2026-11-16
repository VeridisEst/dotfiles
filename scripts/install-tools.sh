#!/usr/bin/env bash
set -euo pipefail
release=${1:?release directory}
source_dir=${2:?source directory}
system_deps=${3:?system dependencies flag}
[[ ! -f $release/TOOLS_READY ]] || { echo 'Vastgelegde codehulp is al geinstalleerd.'; exit 0; }
if ((system_deps)); then
  sudo_cmd=()
  if ((EUID != 0)); then sudo_cmd=(sudo); fi
  "${sudo_cmd[@]}" apt-get install -y --no-install-recommends python3-venv ruby ruby-dev build-essential libyaml-dev libffi-dev zlib1g-dev pkg-config
fi
python3 -m venv "$release/python"
"$release/python/bin/pip" install --disable-pip-version-check -r "$source_dir/tools/python-requirements.txt"
"$release/python/bin/pip" freeze > "$release/python-installed.txt"
mkdir -p "$release/gems" "$release/ruby" "$release/ruby-bin"
GEM_HOME="$release/gems" GEM_PATH="$release/gems" gem install bundler --version 2.5.23 --no-document --install-dir "$release/gems" --bindir "$release/gems/bin"
cp "$source_dir/tools/Gemfile" "$release/ruby/Gemfile"
GEM_HOME="$release/gems" GEM_PATH="$release/gems" BUNDLE_GEMFILE="$release/ruby/Gemfile" BUNDLE_PATH="$release/gems" "$release/gems/bin/bundle" _2.5.23_ install
python3 "$source_dir/scripts/write-ruby-launchers.py" "$release"
"$release/python/bin/pylsp" --version
"$release/ruby-bin/solargraph" --version
touch "$release/TOOLS_READY"
