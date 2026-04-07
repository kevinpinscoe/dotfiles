#!/usr/bin/env bash
set -euo pipefail

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Working tree is dirty. Commit or stash changes first."
  exit 1
fi

git pull

cp -v bash/.bashrc "$HOME/.bashrc"
cp -v bash/.bash_profile "$HOME/.bash_profile"

if [[ "$(uname)" == "Darwin" ]]; then
  cp -v bash/.zshrc "$HOME/.zshrc"
  cp -v bash/.zprofile "$HOME/.zprofile"
fi

rsync -av --delete bash/.bash.d/ "$HOME/.bash.d/"

rsync -av --delete vim/.vim/ "$HOME/.vim/"
cp -v vim/.vimrc "$HOME/.vimrc"

# Cheat
rsync -av --delete \
  --exclude='cheatsheets/' \
  .config/cheat/ \
  "$HOME/.config/cheat/"

rsync -av --delete \
  cheats/ \
  "$HOME/cheats/"

# Install community cheats if they do not already exist
mkdir -p "$HOME/.config/cheat/cheatsheets"

if [[ ! -d "$HOME/.config/cheat/cheatsheets/community" ]]; then
  git clone \
    https://github.com/cheat/cheatsheets \
    "$HOME/.config/cheat/cheatsheets/community"
fi
