# ~/.zprofile - sourced for login shells (macOS Terminal opens login shells)
# Sets up PATH and environment before .zshrc runs.
# Mirrors the login environment from .bash_profile -> .bashrc -> 01_bashrc_mac_env

# Homebrew - must come first so all brew-installed tools are on PATH
eval "$(/opt/homebrew/bin/brew shellenv)"

# GitHub token for Homebrew
if [[ -r "$HOME/.homebrew/gh-token" ]]; then
    IFS= read -r HOMEBREW_GITHUB_API_TOKEN < "$HOME/.homebrew/gh-token"
    export HOMEBREW_GITHUB_API_TOKEN
fi

# PostgreSQL
export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"

# Dotnet
dotnet_roots=(/opt/homebrew/Cellar/dotnet/*/libexec)
if [ -d "${dotnet_roots[-1]}" ]; then
    export DOTNET_ROOT="${dotnet_roots[-1]}"
fi
unset dotnet_roots
export PATH="$PATH:$HOME/.dotnet/tools"

# Core user bins and tools
export PATH="$HOME/bin:$HOME/.local/bin:$HOME/tools:$HOME/go/bin:$PATH"

# macOS system cryptex
export PATH="$PATH:/System/Cryptexes/App/usr/bin"
