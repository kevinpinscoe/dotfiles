# The following lines were added by Docker Desktop to add commands to your PATH.
export PATH="$PATH:/Users/kevini/.docker/bin"
# End of Docker Desktop section.

# ~/.zprofile - sourced for login shells (macOS Terminal opens login shells)
# Sets up PATH and environment before .zshrc runs.
# Mirrors the login environment from .bash_profile -> .bashrc -> 01_bashrc_mac_env

# Private secrets — sourced on ALL machines that share ~/.dotfiles, so this must
# stay above the Darwin gate below. The file itself is a no-op where `op` is absent.
[[ -f "$HOME/.environment/zsh_secrets.sh" ]] && source "$HOME/.environment/zsh_secrets.sh"

[[ "$(uname)" != "Darwin" ]] && return

# Homebrew - must come first so all brew-installed tools are on PATH
eval "$(/opt/homebrew/bin/brew shellenv)"

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
