# ~/.zshrc - sourced for interactive zsh shells only

# Determine OS
IS_MACOS=false
IS_FEDORA=false
IS_DEBIAN=false
[[ "$(uname)" == "Darwin" ]] && IS_MACOS=true
[ -f /etc/fedora-release ] && IS_FEDORA=true
[ -f /etc/debian_version ] && IS_DEBIAN=true

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
        elif [[ "$file" == *debian* ]]; then
            [[ "$IS_DEBIAN" == "true" ]] && source "$file"
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

# zsh-sage wraps self-insert via ZLE widgets; on this Homebrew zsh the
# default FUNCNEST=700 is too tight and trips
# "_sage_suggest_widget:5: maximum nested function level reached".
# Raise the ceiling before the plugin registers its wrappers.
export FUNCNEST=1000

# zsh-sage: intelligent autosuggestions (macOS only)
# Loading from the local fork (kevin/clamp-postdisplay-width branch) instead
# of the Homebrew Cellar copy while testing the POSTDISPLAY width-clamp fix
# for the tmux history-recall cursor bug. Revert to the Homebrew path below
# once the fix is confirmed and upstreamed/tapped:
#   source /opt/homebrew/opt/zsh-sage/zsh-sage.plugin.zsh
if [[ -f ~/Projects/public/zsh-sage/zsh-sage.plugin.zsh ]]; then
    source ~/Projects/public/zsh-sage/zsh-sage.plugin.zsh
    # EDITOR=vim makes zsh pick the viins keymap, where right-arrow is bound
    # to vi-forward-char. zsh-sage only wraps forward-char, so the suggestion
    # isn't accepted. Rebind right-arrow in viins to the wrapped forward-char.
    bindkey -M viins "^[[C" forward-char  # CSI sequence
    bindkey -M viins "^[OC" forward-char  # SS3 sequence (application mode)
fi

# zsh-autosuggestions: Linux (Fedora + Debian install to the same path)
if [[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

[[ -f ~/.environment/self-hosted-services.sh ]] && source ~/.environment/self-hosted-services.sh
[[ -f ~/.environment/zsh_secrets.sh ]] && source ~/.environment/zsh_secrets.sh
[[ -f ~/.environment/openbao/openbao-env.sh ]] && source ~/.environment/openbao/openbao-env.sh

# Container-local overrides (not stowed; exists only on hosts that have it)
[[ -f ~/container-zshrc.sh ]] && source ~/container-zshrc.sh

# Disable terminal bell
unsetopt BEEP
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/kevini/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
