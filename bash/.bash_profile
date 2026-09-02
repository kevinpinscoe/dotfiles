# The following lines were added by Docker Desktop to add commands to your PATH.
export PATH="$PATH:/Users/kevini/.docker/bin"
# End of Docker Desktop section.

# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# User specific environment and startup programs
# Rust comes from Homebrew on this host, so ~/.cargo/env does not exist - only a
# rustup install writes it. Guard the source, or every login shell (including the
# `bash -lc` that launchd jobs run under) prints an error and dirties their logs.
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
