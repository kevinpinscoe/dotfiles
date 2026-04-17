#!/usr/bin/env bash
set -euo pipefail

# Saves VS Code config from the live system into this repo.
#
# Shell, vim, aspell, and cheat config are managed by GNU Stow (symlinks), so
# those files ARE the repo — no copying needed. VS Code uses platform-specific
# paths that don't suit stow, so it's still handled here.

auto_yes=false
for arg in "$@"; do
  [[ "$arg" == "-y" || "$arg" == "--yes" ]] && auto_yes=true
done

if [[ "$auto_yes" == false ]]; then
  read -p "Are you sure you wish to overwrite VS Code files in this repo? (yes/no): " confirm
  if [[ "$confirm" != "yes" ]]; then
    echo "Aborting."
    exit 1
  fi
fi

os_type="$(uname -s)"

if [[ "$os_type" == "Linux" ]]; then
  echo "Saving VS Code config (Fedora / personal)"
  dotfiles_vscode="$HOME/.dotfiles/vscode/personal"
  projects_dir="$HOME/Projects"
  pastebooks_dir="$projects_dir/public/pastebooks"

  if command -v code &>/dev/null || [[ -d "$HOME/.config/Code/User" ]]; then
    mkdir -p \
      "$dotfiles_vscode/.config/Code/User" \
      "$dotfiles_vscode/Projects/public/pastebooks/.vscode"

    cp -v \
      "$HOME/.config/Code/User/settings.json" \
      "$dotfiles_vscode/.config/Code/User/settings.json"

    if [[ -f "$HOME/.config/Code/User/keybindings.json" ]]; then
      cp -v \
        "$HOME/.config/Code/User/keybindings.json" \
        "$dotfiles_vscode/.config/Code/User/keybindings.json"
    fi

    if [[ -f "$pastebooks_dir/.vscode/settings.json" ]]; then
      cp -v \
        "$pastebooks_dir/.vscode/settings.json" \
        "$dotfiles_vscode/Projects/public/pastebooks/.vscode/settings.json"
    fi

    if [[ -f "$projects_dir/home-projects.code-workspace" ]]; then
      cp -v \
        "$projects_dir/home-projects.code-workspace" \
        "$dotfiles_vscode/Projects/home-projects.code-workspace"
    fi

    if [[ -f "$HOME/.config/Code/User/chatLanguageModels.json" ]]; then
      cp -v \
        "$HOME/.config/Code/User/chatLanguageModels.json" \
        "$dotfiles_vscode/.config/Code/User/chatLanguageModels.json"
    fi

    if [[ -d "$HOME/.config/Code/User/snippets" ]]; then
      rsync -av --delete \
        "$HOME/.config/Code/User/snippets/" \
        "$dotfiles_vscode/.config/Code/User/snippets/"
    fi

    if command -v code &>/dev/null; then
      code --list-extensions > "$dotfiles_vscode/extensions.txt"
      echo "Saved VS Code extensions list"
    fi
  else
    echo "VS Code not found, skipping VS Code config"
  fi
fi

if [[ "$os_type" == "Darwin" ]]; then
  echo "Saving VS Code config (macOS / professional)"
  dotfiles_vscode="$HOME/.dotfiles/vscode/professional"
  projects_dir="$HOME/Projects"

  mkdir -p \
    "$dotfiles_vscode/Library/Application Support/Code/User" \
    "$dotfiles_vscode/Projects"

  cp -v \
    "$HOME/Library/Application Support/Code/User/settings.json" \
    "$dotfiles_vscode/Library/Application Support/Code/User/settings.json"

  cp -v \
    "$HOME/Library/Application Support/Code/User/keybindings.json" \
    "$dotfiles_vscode/Library/Application Support/Code/User/keybindings.json"

  if [[ -f "$HOME/Library/Application Support/Code/User/chatLanguageModels.json" ]]; then
    cp -v \
      "$HOME/Library/Application Support/Code/User/chatLanguageModels.json" \
      "$dotfiles_vscode/Library/Application Support/Code/User/chatLanguageModels.json"
  fi

  if [[ -d "$HOME/Library/Application Support/Code/User/snippets" ]]; then
    mkdir -p "$dotfiles_vscode/Library/Application Support/Code/User/snippets"
    rsync -av --delete \
      "$HOME/Library/Application Support/Code/User/snippets/" \
      "$dotfiles_vscode/Library/Application Support/Code/User/snippets/"
  fi

  cp -v \
    "$projects_dir/kevins-work.code-workspace" \
    "$dotfiles_vscode/Projects/kevins-work.code-workspace"

  if command -v code &>/dev/null; then
    code --list-extensions > "$dotfiles_vscode/extensions.txt"
    echo "Saved VS Code extensions list"
  fi
fi
