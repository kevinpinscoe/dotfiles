#!/usr/bin/env bash
# Platform-aware clipboard copy with CR and newline stripping.
# Called by tmux copy-pipe; reads selection from stdin.
content=$(cat | tr -d $'\r\n')
if [[ "$(uname)" == "Darwin" ]]; then
    printf '%s' "$content" | copyq copy -
else
    # tmux strips WAYLAND_DISPLAY from pane environments; re-derive it from the socket.
    if [[ -z "$WAYLAND_DISPLAY" ]]; then
        wayland_sock=$(ls /run/user/"$(id -u)"/wayland-* 2>/dev/null | head -1)
        [[ -n "$wayland_sock" ]] && export WAYLAND_DISPLAY=$(basename "$wayland_sock")
    fi
    if [[ -n "$WAYLAND_DISPLAY" ]] && command -v wl-copy >/dev/null 2>&1; then
        printf '%s' "$content" | wl-copy
    else
        printf '%s' "$content" | DISPLAY=:0 xsel --clipboard --input 2>/dev/null
    fi
    ~/.local/bin/broadcast_clip_from_pi.sh 2>/dev/null &
fi
