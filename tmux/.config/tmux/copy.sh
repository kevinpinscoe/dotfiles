#!/usr/bin/env bash
# Platform-aware clipboard copy with CR and newline stripping.
# Called by tmux copy-pipe; reads selection from stdin.
content=$(cat | tr -d $'\r\n')
if [[ "$(uname)" == "Darwin" ]]; then
    printf '%s' "$content" | copyq copy -
else
    if copyq version >/dev/null 2>&1; then
        printf '%s' "$content" | copyq copy -
    else
        # copyq not running — fall back to native Wayland clipboard
        if [[ -z "$WAYLAND_DISPLAY" ]]; then
            wayland_sock=$(ls /run/user/"$(id -u)"/wayland-* 2>/dev/null | head -1)
            [[ -n "$wayland_sock" ]] && export WAYLAND_DISPLAY=$(basename "$wayland_sock")
        fi
        if [[ -n "$WAYLAND_DISPLAY" ]] && command -v wl-copy >/dev/null 2>&1; then
            printf '%s' "$content" | wl-copy
        else
            printf '%s' "$content" | DISPLAY=:0 xsel --clipboard --input 2>/dev/null
        fi
    fi
    # Clipboard broadcast is Pi-only by design: rpi5/core is the sole originator,
    # pushing its clipboard out to Fedora and the Mac. No host broadcasts back, so
    # this script exists only on the Pi. Guard it so its absence elsewhere is
    # explicit rather than an error silently swallowed by 2>/dev/null.
    if [[ -x ~/.local/bin/broadcast_clip_from_pi.sh ]]; then
        ~/.local/bin/broadcast_clip_from_pi.sh 2>/dev/null &
    fi
fi
