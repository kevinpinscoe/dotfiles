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
  echo "ERROR: stow not found. Install it first:" >&2
  echo "  Fedora : sudo dnf install stow" >&2
  echo "  macOS  : brew install stow" >&2
  echo "  Debian : sudo apt install stow" >&2
  exit 1
fi

# ~/.config/cheat/ must be a real directory so stow symlinks conf.yml inside it
# rather than making the whole directory a symlink (community cheatsheets live
# alongside conf.yml and must not be tracked in this repo).
mkdir -p "$HOME/.config/cheat"

# ~/.config/git/ must be a real directory so stow symlinks ignore and hooks/
# inside it rather than symlinking the whole directory — git may also write
# credentials or other runtime files alongside the tracked config.
mkdir -p "$HOME/.config/git"
# hooks/ must also be a real directory so stow symlinks each hook file
# individually rather than symlinking the whole directory.
mkdir -p "$HOME/.config/git/hooks"

# ~/.config/tmux/status/ must be a real directory so stow symlinks scripts
# inside it per-file rather than symlinking the whole directory.
mkdir -p "$HOME/.config/tmux/status"
# Remove any absolute symlinks stow won't adopt (stow only owns relative ones).
while IFS= read -r -d '' link; do
  target="$(readlink "$link")"
  [[ "$target" = /* ]] && rm "$link"
done < <(find "$HOME/.config/tmux/status" -maxdepth 1 -type l -print0)

PACKAGES=(bash vim aspell cheat home tmux git)
for pkg in "${PACKAGES[@]}"; do
  if [[ -d "$DOTFILES_DIR/$pkg" ]]; then
    stow -d "$DOTFILES_DIR" -t "$HOME" --restow "$pkg"
    echo "Stowed: $pkg"
  fi
done

# ghostty config is platform-specific (tmux binary path differs per OS)
OS="$(uname -s)"
GHOSTTY_PKG=""
if [[ "$OS" == "Darwin" ]]; then
  GHOSTTY_PKG="ghostty-mac"
elif [[ "$OS" == "Linux" ]]; then
  if grep -qi "fedora" /etc/os-release 2>/dev/null; then
    GHOSTTY_PKG="ghostty-fedora"
  elif grep -qi "debian\|ubuntu\|raspbian" /etc/os-release 2>/dev/null; then
    GHOSTTY_PKG="ghostty-debian"
  fi
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
