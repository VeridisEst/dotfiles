#!/usr/bin/env bash
set -euo pipefail
source_dir=$(cd "$(dirname "$0")/.." && pwd)
test_home=$(mktemp -d)
export HOME=$test_home
unset XDG_CONFIG_HOME XDG_DATA_HOME XDG_STATE_HOME XDG_CACHE_HOME NVIM_APPNAME VERIDIS_RELEASE NVIM_DOCUMENTS
export NVIM_DOCUMENTS="$HOME/documenten"
bash -n "$source_dir/install.sh" "$source_dir/scripts/connect-documents.sh"
bash "$source_dir/install.sh" --source "$source_dir"
"$HOME/.local/bin/nvim" --headless -i NONE "+luafile $source_dir/tests/lsp.lua"
printf '\nPersoonlijke notitie die behouden moet blijven.\n' >> "$HOME/documenten/werk/taken.md"
before=$(sha256sum "$HOME/documenten/werk/taken.md")
printf '\n-- existing user customization\n' >> "$HOME/.config/veridis-nvim/init.lua"
bash "$source_dir/install.sh" --source "$source_dir" --no-system
[[ $(sha256sum "$HOME/documenten/werk/taken.md") == "$before" ]]
grep -q 'existing user customization' "$HOME"/.config/veridis-nvim.backup.*/init.lua
test ! -e "$HOME/documenten/.git"
SSH_CONNECTION='127.0.0.1 1000 127.0.0.1 22' "$HOME/.local/bin/nvim" --headless -i NONE "+luafile $source_dir/tests/smoke.lua"
echo 'INSTALL_OK: clean install, two language servers, reinstall preserves documents and backs up config, SSH startup, no document Git repository'
