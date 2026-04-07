#!/usr/bin/env bash
set -euo pipefail

# Make sure we want to overwrite
read -p "Are you sure you wish to overwrite the files in this repo? (yes/no): " confirm
if [[ "$confirm" != "yes" ]]; then
    echo "Aborting."
    exit 1
fi

cp -v ~/.bashrc bash/.bashrc
cp -v ~/.bash_profile bash/.bash_profile
mkdir -p bash/.bash.d
rsync -av --delete ~/.bash.d/ bash/.bash.d/
# vscode
os_type="$(uname -s)"

if [[ "$os_type" == "Linux" ]]; then
  echo "I am Linux"
  dotfiles_vscode="$HOME/.dotfiles/vscode/personal"
  projects_dir="$HOME/Projects"
  pastebooks_dir="$projects_dir/public/pastebooks"

  mkdir -p \
    "$dotfiles_vscode/.config/Code/User" \
    "$dotfiles_vscode/Projects/public/pastebooks/.vscode"

  # User settings
  cp -v \
    "$HOME/.config/Code/User/settings.json" \
    "$dotfiles_vscode/.config/Code/User/settings.json"

  # Pastebooks project settings
  if [[ -f "$pastebooks_dir/.vscode/settings.json" ]]; then
    cp -v \
      "$pastebooks_dir/.vscode/settings.json" \
      "$dotfiles_vscode/Projects/public/pastebooks/.vscode/settings.json"
  fi

  # Project workspace
  cp -v \
    "$projects_dir/home-projects.code-workspace" \
    "$dotfiles_vscode/Projects/home-projects.code-workspace"

  # User chatlanguagemodel
  cp -v \
    "$HOME/.config/Code/User/chatLanguageModels.json" \
    "$dotfiles_vscode/.config/Code/User/chatLanguageModels.json"

  # User snippets
  rsync -av --delete \
    "$HOME/.config/Code/User/snippets/" \
    "$dotfiles_vscode/.config/Code/User/snippets/"
fi

if [[ "$os_type" == "Darwin" ]]; then
  echo "I am Mac"
  cp -v ~/.zshrc bash/.zshrc
  cp -v ~/.zprofile bash/.zprofile
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

  cp -v \
    "$projects_dir/kevins-work.code-workspace" \
    "$dotfiles_vscode/Projects/kevins-work.code-workspace"
fi

# vim
cp -v ~/.vimrc vim/.vimrc
rsync -av --delete ~/.vim/ vim/.vim/

# Cheat
rsync -av --delete \
  --exclude='cheatsheets/' \
  "$HOME/.config/cheat/" \
  "$HOME/.dotfiles/.config/cheat/"

rsync -av --delete \
  "$HOME/cheats/" \
  "$HOME/.dotfiles/cheats/"
