#!/usr/bin/env bash
#
# bootstrap.sh
# Clones the dotfiles repo and installs every top-level entry of DOTFILES_SUBDIR into ~/.config
# Existing targets are backed up to <target>.bak.<timestamp> before being replaced.
#
# Usage: ./bootstrap.sh
#        DOTFILES_REPO=<url> DOTFILES_BRANCH=<branch> DOTFILES_SUBDIR=<path> ./bootstrap.sh
#
# DOTFILES_SUBDIR is relative to the repo root; set it to "." if the dotfiles live at the root.

set -euo pipefail

DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/coko7/archy-factory.git}"
DOTFILES_BRANCH="${DOTFILES_BRANCH:-}"
DOTFILES_SUBDIR="${DOTFILES_SUBDIR:-dotfiles}"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

if [[ $EUID -eq 0 ]]; then
  echo "Run this as your normal user, not root." >&2
  exit 1
fi

if ! command -v git &>/dev/null; then
  echo "git is required but not installed." >&2
  exit 1
fi

CLONE_DIR="$(mktemp --directory)"
trap 'rm -rf "$CLONE_DIR"' EXIT

echo ">>> Cloning $DOTFILES_REPO..."
git clone --depth 1 ${DOTFILES_BRANCH:+--branch "$DOTFILES_BRANCH"} "$DOTFILES_REPO" "$CLONE_DIR"

SOURCE_DIR="$CLONE_DIR/$DOTFILES_SUBDIR"
if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "Subdirectory '$DOTFILES_SUBDIR' not found in $DOTFILES_REPO" >&2
  exit 1
fi

mkdir --parents "$CONFIG_DIR"

shopt -s dotglob nullglob
for src in "$SOURCE_DIR"/*; do
  name="$(basename "$src")"
  [[ "$name" == ".git" ]] && continue

  dest="$CONFIG_DIR/$name"

  if [[ -e "$dest" || -L "$dest" ]]; then
    backup="$dest.bak.$TIMESTAMP"
    echo ">>> Backing up $dest -> $backup"
    mv "$dest" "$backup"
  fi

  echo ">>> Installing $name -> $dest"
  cp --recursive "$src" "$dest"
done

echo
echo ">>> Done. Dotfiles installed into $CONFIG_DIR"
