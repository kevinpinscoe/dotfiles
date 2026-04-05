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

if [[ "$(hostname -s)" == "kevin" ]]; then
  echo "Restoring VS Code config for Fedora"
  dotfiles_vscode="$HOME/.dotfiles/vscode/personal"

  mkdir -p "$HOME/.config/Code/User/snippets"

  cp -v \
    "$dotfiles_vscode/.config/Code/User/settings.json" \
    "$HOME/.config/Code/User/settings.json"

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
    cp -v \
      "$dotfiles_vscode/Projects/kevininscoe.com/pastebooks/.vscode/settings.json" \
      "$pastebooks_dir/.vscode/settings.json"
  fi

  projects_dir="$HOME/Projects"
  if [[ -d "$projects_dir" ]]; then
    cp -v \
      "$dotfiles_vscode/Projects/home-projects.code-workspace" \
      "$projects_dir/home-projects.code-workspace"
  fi

elif [[ "$(hostname -s)" == "MacBook" ]]; then
  echo "Restoring VS Code config for macOS"
  dotfiles_vscode="$HOME/.dotfiles/vscode/professional"
  vscode_user="$HOME/Library/Application Support/Code/User"

  mkdir -p "$vscode_user"

  cp -v \
    "$dotfiles_vscode/Library/Application Support/Code/User/settings.json" \
    "$vscode_user/settings.json"

  cp -v \
    "$dotfiles_vscode/Library/Application Support/Code/User/keybindings.json" \
    "$vscode_user/keybindings.json"

  projects_dir="$HOME/Projects"
  if [[ -d "$projects_dir" ]]; then
    cp -v \
      "$dotfiles_vscode/Projects/kevins-work.code-workspace" \
      "$projects_dir/kevins-work.code-workspace"
  fi

else
  echo "Unrecognized hostname '$(hostname -s)' — no VS Code config defined for this host."
  exit 1
fi

echo "VS Code restore complete."
