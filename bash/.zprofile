# ~/.zprofile - sourced for login shells (macOS Terminal opens login shells)
# Sets up PATH and environment before .zshrc runs.
# Mirrors the login environment from .bash_profile -> .bashrc -> 01_bashrc_mac_env

[[ "$(uname)" != "Darwin" ]] && return

# Homebrew - must come first so all brew-installed tools are on PATH
eval "$(/opt/homebrew/bin/brew shellenv)"

# GitHub token for Homebrew (private ACST org taps).
# Migrated 2026-06-22 from plaintext ~/.homebrew/gh-token to 1Password
# (Employee vault, "GitHub PAT - homebrew (mac)"). Fetched lazily on first
# `brew` call so we don't pay op's ~3s latency on every shell startup.
brew() {
    if [[ -z "$HOMEBREW_GITHUB_API_TOKEN" ]] && command -v op >/dev/null 2>&1; then
        HOMEBREW_GITHUB_API_TOKEN="$(op read --account acst.1password.com \
            'op://Employee/g3eycecdhipnznib5v55qnzglm/credential' 2>/dev/null)"
        [[ -n "$HOMEBREW_GITHUB_API_TOKEN" ]] && export HOMEBREW_GITHUB_API_TOKEN
    fi
    command brew "$@"
}

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
