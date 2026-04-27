# ~/.zshrc - sourced for interactive zsh shells only

# Determine OS
IS_MACOS=false
IS_FEDORA=false
[[ "$(uname)" == "Darwin" ]] && IS_MACOS=true
[ -f /etc/fedora-release ] && IS_FEDORA=true

# Initialize zsh completion system (needed before compdef calls in ~/.bash.d/*)
autoload -Uz compinit && compinit

# Source appropriate files from ~/.bash.d/
# Skip bash-only files; mac-tagged files only on macOS; fedora-tagged files only on Fedora
for file in ~/.bash.d/*; do
    if [ -f "$file" ]; then
        [[ "$file" == *_bash_* ]] && continue
        [[ "$file" == *.md ]] && continue
        if [[ "$file" == *mac* ]]; then
            [[ "$IS_MACOS" == "true" ]] && source "$file"
        elif [[ "$file" == *fedora* ]]; then
            [[ "$IS_FEDORA" == "true" ]] && source "$file"
        else
            source "$file"
        fi
    fi
done

# 077 would be more secure, but 022 is generally quite realistic
umask 002

# Locale
LANG="en_US.UTF-8"
LC_COLLATE="C"
export LANG
export LC_COLLATE

if [[ -n "$SSH_CLIENT" ]]; then
    sshvars=($SSH_CLIENT)
    echo "I am logged in from ${sshvars[1]}"
    echo " "
fi

# zsh-sage: intelligent autosuggestions (Homebrew; macOS only)
[[ -f /opt/homebrew/opt/zsh-sage/zsh-sage.plugin.zsh ]] && source /opt/homebrew/opt/zsh-sage/zsh-sage.plugin.zsh
