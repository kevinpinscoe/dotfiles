#!/usr/bin/env bash
# Platform-aware clipboard copy with CR stripping.
# Called by tmux copy-pipe; reads selection from stdin.
content=$(cat | tr -d $'\r')
if [[ "$(uname)" == "Darwin" ]]; then
    printf '%s' "$content" | copyq copy -
else
    printf '%s' "$content" | DISPLAY=:99 copyq copy -
    ~/.local/bin/broadcast_clip_from_pi.sh 2>/dev/null &
fi
