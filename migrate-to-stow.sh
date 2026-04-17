#!/usr/bin/env bash
set -euo pipefail

# One-time migration: restructure repo and symlink dotfiles via GNU Stow.
# After this runs, edit files directly in the repo — they're live via symlinks.
# Re-run install.sh on new hosts; this script is only needed once.

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# ── Install stow ──────────────────────────────────────────────────────────────
install_stow() {
  if command -v stow &>/dev/null; then
    echo "stow already installed: $(stow --version | head -1)"
    return
  fi
  local os
  os="$(uname -s)"
  if [[ "$os" == "Linux" ]]; then
    echo "Installing stow via dnf..."
    sudo dnf install -y stow
  elif [[ "$os" == "Darwin" ]]; then
    echo "Installing stow via brew..."
    brew install stow
  else
    echo "ERROR: Unknown OS '$os'. Install stow manually, then re-run." >&2
    exit 1
  fi
}

# ── Restructure repo for stow ─────────────────────────────────────────────────
restructure_repo() {
  cd "$DOTFILES_DIR"

  # .config/cheat/ → cheat/.config/cheat/  (new 'cheat' stow package)
  if [[ -d "$DOTFILES_DIR/.config" && ! -d "$DOTFILES_DIR/cheat/.config" ]]; then
    mkdir -p cheat
    git mv .config cheat/.config
    echo "Moved .config/ → cheat/.config/"
  else
    echo "cheat package already restructured, skipping"
  fi

  # cheats/ → home/cheats/  (new 'home' stow package)
  if [[ -d "$DOTFILES_DIR/cheats" && ! -d "$DOTFILES_DIR/home/cheats" ]]; then
    mkdir -p home
    git mv cheats home/cheats
    echo "Moved cheats/ → home/cheats/"
  else
    echo "home package already restructured, skipping"
  fi
}

# ── Back up and remove conflicting live files ─────────────────────────────────
# Stow refuses to overwrite real files; we back them up first.
backup_and_remove() {
  local path="$1"
  if [[ -L "$path" ]]; then
    rm "$path"
    echo "Removed existing symlink: $path"
  elif [[ -e "$path" ]]; then
    local rel="${path#"$HOME"/}"
    local dest="$BACKUP_DIR/$rel"
    mkdir -p "$(dirname "$dest")"
    cp -rp "$path" "$dest"
    rm -rf "$path"
    echo "Backed up: $path → $dest"
  fi
}

backup_conflicts() {
  mkdir -p "$BACKUP_DIR"

  # bash
  backup_and_remove "$HOME/.bashrc"
  backup_and_remove "$HOME/.bash_profile"
  backup_and_remove "$HOME/.bash.d"
  backup_and_remove "$HOME/.zshrc"
  backup_and_remove "$HOME/.zprofile"

  # vim
  backup_and_remove "$HOME/.vimrc"
  backup_and_remove "$HOME/.vim"

  # aspell
  backup_and_remove "$HOME/.aspell.en.pws"

  # cheat config — ensure ~/.config/cheat/ is a real dir so stow folds correctly
  # (community cheatsheets live at ~/.config/cheat/cheatsheets/ and must not be
  # inside the repo)
  mkdir -p "$HOME/.config/cheat"
  backup_and_remove "$HOME/.config/cheat/conf.yml"

  # cheats content directory
  backup_and_remove "$HOME/cheats"
}

# ── Stow all packages ─────────────────────────────────────────────────────────
stow_packages() {
  local packages=(bash vim aspell cheat home)
  for pkg in "${packages[@]}"; do
    if [[ -d "$DOTFILES_DIR/$pkg" ]]; then
      stow -d "$DOTFILES_DIR" -t "$HOME" "$pkg"
      echo "Stowed: $pkg"
    else
      echo "WARNING: package dir '$pkg' not found, skipping"
    fi
  done
}

# ── Clone community cheatsheets if absent ─────────────────────────────────────
install_community_cheats() {
  local dest="$HOME/.config/cheat/cheatsheets/community"
  if [[ ! -d "$dest" ]]; then
    echo "Cloning community cheatsheets..."
    git clone https://github.com/cheat/cheatsheets "$dest"
  else
    echo "Community cheatsheets already present: $dest"
  fi
}

# ── Main ──────────────────────────────────────────────────────────────────────
echo "=== Migrating dotfiles to GNU Stow ==="
echo "Dotfiles dir : $DOTFILES_DIR"
echo "Backup dir   : $BACKUP_DIR"
echo ""

install_stow
restructure_repo
backup_conflicts
stow_packages
install_community_cheats

echo ""
echo "=== Migration complete ==="
echo ""
echo "Symlinks created in $HOME for packages: bash vim aspell cheat home"
echo "Backups (if any): $BACKUP_DIR"
echo ""
echo "NOT managed by stow (use copy.sh / restore.sh as before):"
echo "  VS Code config  — platform-specific paths, copy.sh / restore.sh"
echo ""
echo "Workflow going forward:"
echo "  Edit files directly in $DOTFILES_DIR — changes are live immediately."
echo "  New host setup  : bash install.sh"
echo "  Add a new file  : place it in the correct stow package, re-run stow"
echo "  VS Code backup  : bash copy.sh"
echo "  VS Code restore : bash restore.sh"
