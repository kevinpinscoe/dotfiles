#!/usr/bin/env bash
# ~/.config/tmux/scripts/session-dashboard.sh
# Auto-refreshing box-grid overview of all tmux sessions.
#
# Launch via tmux: prefix + D  (see tmux.conf — opens in a dedicated window)
# Standalone:      ~/.config/tmux/scripts/session-dashboard.sh
# One-shot output: ~/.config/tmux/scripts/session-dashboard.sh --once
#
# Shows for each session:
#   - Session name and window count
#   - ● LIVE (currently attached) or ○ idle
#   - Last connected date and time
#   - Last few lines of the active pane (stripped of ANSI for alignment)

set -euo pipefail

PREVIEW_LINES=5
REFRESH_SECS=3
ONCE=0
[[ "${1:-}" == "--once" ]] && ONCE=1

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

_fmt_time() {
    local ts="${1:-0}"
    if [[ "${ts}" -gt 0 ]]; then
        date -r "${ts}" "+%Y-%m-%d %H:%M" 2>/dev/null || \
        date -d "@${ts}" "+%Y-%m-%d %H:%M" 2>/dev/null || \
        echo "?"
    else
        echo "never"
    fi
}

_strip_ansi() {
    sed 's/\x1b\[[0-9;]*[mKJHf]//g; s/\r//g'
}

_hr() { printf '─%.0s' $(seq 1 "${1}"); }

# ---------------------------------------------------------------------------
# Draw one session box
# ---------------------------------------------------------------------------

_draw_box() {
    local name="${1}" ts="${2}" attached="${3}" windows="${4}"
    local TERM_WIDTH BOX_WIDTH
    TERM_WIDTH=$(tput cols 2>/dev/null || echo 100)
    BOX_WIDTH=$(( TERM_WIDTH - 2 ))

    # Time + status
    local last
    last=$(_fmt_time "${ts}")

    local badge badge_color
    if [[ "${attached:-0}" -gt 0 ]]; then
        badge="● LIVE"
        badge_color=$'\033[32m'
    else
        badge="○ idle"
        badge_color=$'\033[2m'
    fi

    # Header layout: ┌─ NAME ──── badge  time  Nw ─┐
    local name_part=" ${name} "
    local meta_part=" ${badge_color}${badge}$'\033[0m'  ${last}  ${windows}w "
    local meta_plain=" ${badge}  ${last}  ${windows}w "  # for length calc (no ANSI)
    local dashes=$(( BOX_WIDTH - ${#name_part} - ${#meta_plain} - 2 ))
    [[ ${dashes} -lt 1 ]] && dashes=1

    printf '┌─\033[1;36m%s\033[0m' "${name_part}"
    _hr "${dashes}"
    printf '%s%s\033[0m─┐\n' "${badge_color}" "${meta_plain}"

    # Capture and strip ANSI from pane content so we can pad correctly
    local raw_content
    raw_content=$(tmux capture-pane -t "${name}" -p 2>/dev/null \
        | _strip_ansi | grep -v '^[[:space:]]*$' | tail -"${PREVIEW_LINES}") \
        || raw_content=""

    if [[ -z "${raw_content}" ]]; then
        local empty_line="  (no recent output)"
        local pad=$(( BOX_WIDTH - ${#empty_line} - 1 ))
        [[ $pad -lt 0 ]] && pad=0
        printf '│\033[2m%s\033[0m%*s│\n' "${empty_line}" "${pad}" ""
    else
        while IFS= read -r line; do
            # Trim to fit inside box
            local max=$(( BOX_WIDTH - 3 ))  # 1 leading space, 1 trailing space, 1 for right │
            if [[ ${#line} -gt ${max} ]]; then
                line="${line:0:$(( max - 3 ))}..."
            fi
            local pad=$(( BOX_WIDTH - ${#line} - 2 ))
            [[ $pad -lt 0 ]] && pad=0
            printf '│ %s%*s│\n' "${line}" "${pad}" ""
        done <<< "${raw_content}"
    fi

    # Bottom border
    printf '└'
    _hr "${BOX_WIDTH}"
    printf '┘\n\n'
}

# ---------------------------------------------------------------------------
# Render full dashboard to screen
# ---------------------------------------------------------------------------

_render() {
    # Move cursor to top-left and clear (avoids full repaint flicker vs clear)
    printf '\033[H\033[2J'
    printf '\033[1m❯ tmux sessions\033[0m  \033[2mrefreshed %s\033[0m\n\n' "$(date '+%H:%M:%S')"

    local count=0
    while IFS="|" read -r name ts attached windows; do
        _draw_box "${name}" "${ts}" "${attached}" "${windows}"
        (( count++ )) || true
    done < <(tmux list-sessions \
        -F "#{session_name}|#{session_last_attached}|#{session_attached}|#{session_windows}" \
        2>/dev/null || true)

    if [[ ${count} -eq 0 ]]; then
        printf '  \033[2mno tmux sessions found\033[0m\n'
    fi

    if [[ ${ONCE} -eq 0 ]]; then
        printf '\n\033[2m  auto-refreshing every %ds — press q or Ctrl-C to exit\033[0m\n' \
            "${REFRESH_SECS}"
    fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

if [[ ${ONCE} -eq 1 ]]; then
    _render
    exit 0
fi

# Interactive loop mode
# EXIT trap guarantees the cursor comes back no matter how this window dies
# (kill-window, closed terminal tab, killed session, error) — not just on a
# clean 'q' or a caught INT/TERM.
trap 'tput cnorm 2>/dev/null || printf "\033[?25h"' EXIT
trap 'exit 0' INT TERM HUP

tput civis 2>/dev/null || printf '\033[?25l'  # hide cursor while running

while true; do
    _render
    # Read a keypress with 3s timeout; 'q' exits cleanly
    if IFS= read -r -s -n 1 -t "${REFRESH_SECS}" key 2>/dev/null; then
        [[ "${key}" == "q" ]] && break
    fi
done
