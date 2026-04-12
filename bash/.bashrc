# /etc/skel/.bashrc
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !

# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi

### local stuff beyond here

# Determine OS
IS_MACOS=false
[[ "$(uname)" == "Darwin" ]] && IS_MACOS=true

# Source appropriate files from ~/.bash.d/
# Skip zsh-only files; mac-tagged files only on macOS
for file in ~/.bash.d/*; do
    if [ -f "$file" ]; then
        [[ "$file" == *_zsh_* ]] && continue
        [[ "$file" == *.md ]] && continue
        if [[ "$file" == *mac* ]]; then
            [[ "$IS_MACOS" == "true" ]] && source "$file"
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
    echo "I am logged in from ${sshvars[0]}"
    echo " "
fi
