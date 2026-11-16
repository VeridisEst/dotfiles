#!/usr/bin/env bash
set -euo pipefail
destination=${NVIM_DOCUMENTS:-"$HOME/documenten"}
url=https://github.com/VeridisEst/documenten.git
while (($#)); do
  case "$1" in
    --ssh) url=git@github.com:VeridisEst/documenten.git; shift ;;
    --dir) destination=${2:?missing directory}; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done
command -v git >/dev/null || { echo 'Install Git first.' >&2; exit 1; }
command -v python3 >/dev/null || { echo 'Install Python 3 first.' >&2; exit 1; }
destination=$(python3 -c 'import os,sys; print(os.path.abspath(os.path.expanduser(sys.argv[1])))' "$destination")
[[ $destination != / && $destination != "$HOME" && ! -L $destination ]] || { echo 'Unsafe destination.' >&2; exit 1; }
if [[ -d $destination/.git ]]; then
  echo "A repository already exists at $destination. Nothing changed."
  git -C "$destination" remote -v
  exit 0
fi
parent=$(dirname "$destination")
mkdir -p "$parent"
scratch=$(mktemp -d "$parent/.documenten-clone.XXXXXXXX")
trap 'rm -rf -- "$scratch"' EXIT
git clone "$url" "$scratch/repository"
[[ -f $scratch/repository/org/overzicht.md && -f $scratch/repository/werk/taken.md && -f $scratch/repository/prive/taken.md ]] || { echo 'Repository is not yet initialized with the document structure.' >&2; exit 1; }
if [[ -e $destination ]]; then
  backup=$destination.backup.$(date +%Y%m%d-%H%M%S).$$
  mv -- "$destination" "$backup"
  echo "Existing local documents preserved at: $backup"
  echo 'Copy any personal content from that backup manually; nothing was uploaded.'
fi
mv "$scratch/repository" "$destination"
echo "Connected: $destination. Pull and push remain manual."
