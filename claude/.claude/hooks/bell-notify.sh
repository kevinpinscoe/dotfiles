#!/bin/bash
# Called by Claude Code Stop and Notification hooks.

if [ -z "$TMUX" ] || [ -z "$TMUX_PANE" ]; then
    exit 0
fi

# Resolve window ID from our specific pane (not from active window)
WIN=$(tmux list-panes -a -F '#{pane_id} #{window_id}' 2>/dev/null \
    | awk -v p="$TMUX_PANE" '$1==p{print $2; exit}')
[ -z "$WIN" ] && exit 0

# Set the red indicator for this window
tmux set-window-option -t "$WIN" @claude_needs_input 1 2>/dev/null

# Session-level (not global) hook: clears the indicator when you switch
# to this specific window, then removes itself.
tmux set-hook -t "$WIN" after-select-window \
    "if-shell 'test \"#{window_id}\" = \"$WIN\"' \
        'set-window-option -t $WIN @claude_needs_input 0 ; set-hook -u -t $WIN after-select-window'" \
    2>/dev/null

exit 0
