#!/usr/bin/env bash
set -euo pipefail

# Applies dotfiles to the live system via GNU Stow (symlinks).
# Run migrate-to-stow.sh first if you haven't already migrated.

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Working tree is dirty. Commit or stash changes first."
  exit 1
fi

git pull

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

if ! command -v stow &>/dev/null; then
  echo "ERROR: stow not found. Install it first (dnf install stow / brew install stow)." >&2
  exit 1
fi

# ~/.config/cheat/ must be a real directory so stow symlinks conf.yml inside it
# rather than making the whole directory a symlink (community cheatsheets live
# alongside conf.yml and must not be tracked in this repo).
mkdir -p "$HOME/.config/cheat"

PACKAGES=(bash vim aspell cheat home tmux)
for pkg in "${PACKAGES[@]}"; do
  if [[ -d "$DOTFILES_DIR/$pkg" ]]; then
    stow -d "$DOTFILES_DIR" -t "$HOME" --restow "$pkg"
    echo "Stowed: $pkg"
  fi
done

# ghostty config is platform-specific (tmux binary path differs)
OS="$(uname -s)"
if [[ "$OS" == "Darwin" ]]; then
  GHOSTTY_PKG="ghostty-mac"
elif [[ "$OS" == "Linux" ]]; then
  GHOSTTY_PKG="ghostty-fedora"
fi
if [[ -n "${GHOSTTY_PKG:-}" && -d "$DOTFILES_DIR/$GHOSTTY_PKG" ]]; then
  mkdir -p "$HOME/.config/ghostty"
  stow -d "$DOTFILES_DIR" -t "$HOME" --restow "$GHOSTTY_PKG"
  echo "Stowed: $GHOSTTY_PKG"
fi

# Clone community cheatsheets if absent
if [[ ! -d "$HOME/.config/cheat/cheatsheets/community" ]]; then
  mkdir -p "$HOME/.config/cheat/cheatsheets"
  git clone https://github.com/cheat/cheatsheets "$HOME/.config/cheat/cheatsheets/community"
fi

echo "Done. Run restore.sh to also restore VS Code config."
