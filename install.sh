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

# ~/.config/cspell/ must be a real directory so stow symlinks custom-words.txt
# inside it rather than symlinking the whole directory.
mkdir -p "$HOME/.config/cspell"

# ~/.config/cheat/ must be a real directory so stow symlinks conf.yml inside it
# rather than making the whole directory a symlink (community cheatsheets live
# alongside conf.yml and must not be tracked in this repo).
mkdir -p "$HOME/.config/cheat"

# ~/.config/git/ must be a real directory so stow symlinks ignore and hooks/
# inside it rather than symlinking the whole directory — git may also write
# credentials or other runtime files alongside the tracked config.
# Remove a stow-folded directory symlink if a previous run left one behind.
[[ -L "$HOME/.config/git" ]] && rm "$HOME/.config/git"
mkdir -p "$HOME/.config/git"
# hooks/ must also be a real directory so stow symlinks each hook file
# individually rather than symlinking the whole directory.
[[ -L "$HOME/.config/git/hooks" ]] && rm "$HOME/.config/git/hooks"
mkdir -p "$HOME/.config/git/hooks"

# ~/.config/tmux/status/ and scripts/ must be real directories so stow
# symlinks files inside them per-file rather than symlinking the whole directory.
mkdir -p "$HOME/.config/tmux/status"
mkdir -p "$HOME/.config/tmux/scripts"

# ~/.config/opensessions/ must be a real directory so stow symlinks config.json
# per-file; the opensessions server also writes session-order.json there at runtime.
mkdir -p "$HOME/.config/opensessions"

# opensessions tmux plugin — clone if not already present. The bin/ files are
# managed by the opensessions stow package; the clone provides the plugin itself.
if [[ ! -d "$HOME/.tmux/plugins/opensessions/.git" ]]; then
  mkdir -p "$HOME/.tmux/plugins"
  git clone https://github.com/Ataraxy-Labs/opensessions.git "$HOME/.tmux/plugins/opensessions"
fi

# ~/.tmux/plugins/opensessions/bin/ must be a real directory so stow symlinks
# the server and sidebar binaries per-file rather than symlinking the whole directory.
mkdir -p "$HOME/.tmux/plugins/opensessions/bin"
# The clone places real binaries here; remove them so stow can create its symlinks.
rm -f "$HOME/.tmux/plugins/opensessions/bin/opensessions-server"
rm -f "$HOME/.tmux/plugins/opensessions/bin/opensessions-sidebar"

# ~/.config/yazi/plugins/ must be a real directory so stow symlinks each plugin
# directory individually rather than symlinking the whole plugins/ directory.
mkdir -p "$HOME/.config/yazi/plugins"
# Remove any absolute symlinks stow won't adopt (stow only owns relative ones).
while IFS= read -r -d '' link; do
  target="$(readlink "$link")"
  [[ "$target" = /* ]] && rm "$link"
done < <(find "$HOME/.config/tmux/status" -maxdepth 1 -type l -print0)

# ~/.claude/hooks/ must be a real directory so stow symlinks hook scripts
# inside it per-file rather than symlinking the whole directory — Claude Code
# writes settings.json and other runtime files into ~/.claude/ alongside hooks/.
mkdir -p "$HOME/.claude/hooks"

PACKAGES=(bash vim aspell cheat cspell home tmux git opensessions yazi claude)
for pkg in "${PACKAGES[@]}"; do
  if [[ -d "$DOTFILES_DIR/$pkg" ]]; then
    stow -d "$DOTFILES_DIR" -t "$HOME" --restow "$pkg"
    echo "Stowed: $pkg"
  fi
done

# ghostty is a GUI terminal emulator — it cannot run inside a container, so
# skip stowing it there even on an otherwise-Fedora/Debian OS match.
IS_CONTAINER=false
[[ -f /.dockerenv ]] && IS_CONTAINER=true
[[ "$(systemd-detect-virt 2>/dev/null)" == "docker" ]] && IS_CONTAINER=true

# ghostty config is platform-specific (tmux binary path differs per OS)
OS="$(uname -s)"
GHOSTTY_PKG=""
if [[ "$IS_CONTAINER" == "false" ]]; then
  if [[ "$OS" == "Darwin" ]]; then
    GHOSTTY_PKG="ghostty-mac"
  elif [[ "$OS" == "Linux" ]]; then
    if grep -qi "fedora" /etc/os-release 2>/dev/null; then
      GHOSTTY_PKG="ghostty-fedora"
    elif grep -qi "debian\|ubuntu\|raspbian" /etc/os-release 2>/dev/null; then
      GHOSTTY_PKG="ghostty-debian"
    fi
  fi
fi
if [[ -n "${GHOSTTY_PKG:-}" && -d "$DOTFILES_DIR/$GHOSTTY_PKG" ]]; then
  mkdir -p "$HOME/.config/ghostty"
  stow -d "$DOTFILES_DIR" -t "$HOME" --restow "$GHOSTTY_PKG"
  echo "Stowed: $GHOSTTY_PKG"
fi

# hammerspoon is macOS-only. ~/.hammerspoon/ must be a real directory so stow
# symlinks init.lua inside it per-file rather than the whole directory —
# Hammerspoon writes Spoons/ and other runtime state alongside init.lua.
if [[ "$OS" == "Darwin" && -d "$DOTFILES_DIR/hammerspoon" ]]; then
  mkdir -p "$HOME/.hammerspoon"
  stow -d "$DOTFILES_DIR" -t "$HOME" --restow hammerspoon
  echo "Stowed: hammerspoon"
fi

# Cursor is macOS-only. ~/Library/Application Support/Cursor/User/ must be
# a real directory so stow symlinks config files inside it per-file rather
# than the whole directory — Cursor writes extensions and other runtime state
# alongside the config files.
if [[ "$OS" == "Darwin" && -d "$DOTFILES_DIR/cursor-professional" ]]; then
  mkdir -p "$HOME/Library/Application Support/Cursor/User"
  stow -d "$DOTFILES_DIR" -t "$HOME" --restow cursor-professional
  echo "Stowed: cursor-professional"
fi

# vscode-personal is Linux-only: it carries the FLDW's multi-root workspace
# file, ~/Projects/home-projects.code-workspace. ~/Projects/ is a real directory
# holding every project checkout, so stow unfolds and symlinks the single file
# inside it rather than the whole directory.
#
# Only the workspace file is stowed. The rest of the VS Code config stays
# snapshot-based via copy.sh / restore.sh, because VS Code rewrites
# settings.json in place whenever a setting is changed through the UI, and the
# personal (Linux) and professional (macOS) settings are different files.
if [[ "$OS" == "Linux" && -d "$DOTFILES_DIR/vscode-personal" ]]; then
  mkdir -p "$HOME/Projects"
  # stow refuses to overwrite a real file. Hosts set up before this package
  # existed have a plain copy left by the old restore.sh flow; move it aside
  # rather than deleting it, so a host-local edit is never silently lost.
  workspace_file="$HOME/Projects/home-projects.code-workspace"
  if [[ -e "$workspace_file" && ! -L "$workspace_file" ]]; then
    mv -v "$workspace_file" "$workspace_file.pre-stow.$(date +%Y%m%d-%H%M%S)"
  fi
  stow -d "$DOTFILES_DIR" -t "$HOME" --restow vscode-personal
  echo "Stowed: vscode-personal"
fi

# zsh-autosuggestions — install if absent (grey-text history suggestions; right-arrow to accept)
if [[ "$OS" == "Linux" ]] && [[ ! -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  if grep -qi "fedora" /etc/os-release 2>/dev/null; then
    sudo dnf install -y zsh-autosuggestions
  elif grep -qi "debian\|ubuntu\|raspbian" /etc/os-release 2>/dev/null; then
    sudo apt install -y zsh-autosuggestions
  fi
fi

# Clone community cheatsheets if absent
if [[ ! -d "$HOME/.config/cheat/cheatsheets/community" ]]; then
  mkdir -p "$HOME/.config/cheat/cheatsheets"
  git clone https://github.com/cheat/cheatsheets "$HOME/.config/cheat/cheatsheets/community"
fi

echo "Done. Run restore.sh to also restore VS Code settings.json and snippets."
echo "(home-projects.code-workspace is stowed, not restored — it is live via symlink.)"
