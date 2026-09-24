#!/usr/bin/env bash

# Post-install setup — hosted at df.coko7.fr/bootstrap.sh
# Run after first boot into the installed system, as your normal user:
#   bash <(curl -sL df.coko7.fr/bootstrap.sh)
set -euo pipefail

GITHUB_USER="coko7" # chezmoi will use github.com/YOURUSER/dotfiles
# Or set a full repo URL instead:
# DOTFILES_REPO="https://github.com/YOURUSER/dotfiles.git"

# ---------------------------------------------------------------
# Safety: run as your user, not root (dotfiles belong to you)
# ---------------------------------------------------------------
if [[ $EUID -eq 0 ]]; then
  echo "Run this as your normal user, not root." >&2
  exit 1
fi

# ---------------------------------------------------------------
# 1. Packages needed for the setup itself
# ---------------------------------------------------------------
echo ">>> Installing chezmoi and git..."
sudo pacman -Sy --needed --noconfirm chezmoi git

# ---------------------------------------------------------------
# 2. Dotfiles via chezmoi
#    init clones github.com/GITHUB_USER/dotfiles, --apply deploys it
# ---------------------------------------------------------------
echo ">>> Applying dotfiles..."
chezmoi init --apply "$GITHUB_USER"
# If using a custom repo URL instead:
# chezmoi init --apply "$DOTFILES_REPO"

# ---------------------------------------------------------------
# 3. (Optional) extra packages beyond what archinstall handled
#    Keep the archinstall config as the main package list; use this
#    for stuff you add later without wanting to regenerate the config.
# ---------------------------------------------------------------
EXTRA_PKGS=(
  # ripgrep fd fzf ...
)
if ((${#EXTRA_PKGS[@]})); then
  echo ">>> Installing extra packages..."
  sudo pacman -S --needed --noconfirm "${EXTRA_PKGS[@]}"
fi

# ---------------------------------------------------------------
# 4. (Optional) AUR helper
# ---------------------------------------------------------------
# if ! command -v paru &>/dev/null; then
#     echo ">>> Installing paru..."
#     sudo pacman -S --needed --noconfirm base-devel
#     tmp=$(mktemp -d)
#     git clone https://aur.archlinux.org/paru-bin.git "$tmp/paru-bin"
#     (cd "$tmp/paru-bin" && makepkg -si --noconfirm)
#     rm -rf "$tmp"
# fi

# ---------------------------------------------------------------
# 5. (Optional) user services
# ---------------------------------------------------------------
# systemctl --user enable --now some.service

echo
echo ">>> Done. Dotfiles applied with chezmoi."
echo "    Update later with: chezmoi update"
