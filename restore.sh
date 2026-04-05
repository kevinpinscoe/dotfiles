#!/usr/bin/env bash
set -euo pipefail

# restore.sh — restores VS Code configuration from this repo to the live system.
# Companion to copy.sh (which captures VS Code config) and install.sh (which
# handles shell/vim/cheat config but not VS Code).
#
# Run this after install.sh on any host where you want VS Code settings restored.

read -p "Are you sure you wish to overwrite VS Code config on this system? (yes/no): " confirm
if [[ "$confirm" != "yes" ]]; then
    echo "Aborting."
    exit 1
fi

# Ensure the parent directory of a destination file exists. If the destination
# is a symlink, resolve it and create the parent of the symlink's target so
# that `cp` (which follows symlinks) can write through it.
ensure_dest_dir() {
  local dest="$1"
  if [[ -L "$dest" ]]; then
    local target
    target="$(readlink "$dest")"
    if [[ "$target" != /* ]]; then
      target="$(dirname "$dest")/$target"
    fi
    mkdir -p "$(dirname "$target")"
  else
    mkdir -p "$(dirname "$dest")"
  fi
}

if [[ "$(uname -s)" == "Linux" ]]; then
  echo "Restoring VS Code config for Fedora"
  dotfiles_vscode="$HOME/.dotfiles/vscode/personal"

  mkdir -p "$HOME/.config/Code/User/snippets"

  ensure_dest_dir "$HOME/.config/Code/User/settings.json"
  cp -v \
    "$dotfiles_vscode/.config/Code/User/settings.json" \
    "$HOME/.config/Code/User/settings.json"

  ensure_dest_dir "$HOME/.config/Code/User/chatLanguageModels.json"
  cp -v \
    "$dotfiles_vscode/.config/Code/User/chatLanguageModels.json" \
    "$HOME/.config/Code/User/chatLanguageModels.json"

  rsync -av --delete \
    "$dotfiles_vscode/.config/Code/User/snippets/" \
    "$HOME/.config/Code/User/snippets/"

  # Restore project settings if the project directory exists
  pastebooks_dir="$HOME/Projects/kevininscoe.com/pastebooks"
  if [[ -d "$pastebooks_dir" ]]; then
    mkdir -p "$pastebooks_dir/.vscode"
    ensure_dest_dir "$pastebooks_dir/.vscode/settings.json"
    cp -v \
      "$dotfiles_vscode/Projects/kevininscoe.com/pastebooks/.vscode/settings.json" \
      "$pastebooks_dir/.vscode/settings.json"
  fi

  projects_dir="$HOME/Projects"
  if [[ -d "$projects_dir" ]]; then
    ensure_dest_dir "$projects_dir/home-projects.code-workspace"
    cp -v \
      "$dotfiles_vscode/Projects/home-projects.code-workspace" \
      "$projects_dir/home-projects.code-workspace"
  fi

elif [[ "$(uname -s)" == "Darwin" ]]; then
  echo "Restoring VS Code config for macOS"
  dotfiles_vscode="$HOME/.dotfiles/vscode/professional"
  vscode_user="$HOME/Library/Application Support/Code/User"

  mkdir -p "$vscode_user"

  ensure_dest_dir "$vscode_user/settings.json"
  cp -v \
    "$dotfiles_vscode/Library/Application Support/Code/User/settings.json" \
    "$vscode_user/settings.json"

  ensure_dest_dir "$vscode_user/keybindings.json"
  cp -v \
    "$dotfiles_vscode/Library/Application Support/Code/User/keybindings.json" \
    "$vscode_user/keybindings.json"

  projects_dir="$HOME/Projects"
  if [[ -d "$projects_dir" ]]; then
    ensure_dest_dir "$projects_dir/kevins-work.code-workspace"
    cp -v \
      "$dotfiles_vscode/Projects/kevins-work.code-workspace" \
      "$projects_dir/kevins-work.code-workspace"
  fi

else
  echo "Unrecognized OS '$(uname -s)' — no VS Code config defined for this platform."
  exit 1
fi

echo "VS Code restore complete."
