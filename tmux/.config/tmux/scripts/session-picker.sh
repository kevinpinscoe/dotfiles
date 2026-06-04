#!/usr/bin/env bash
# ~/.config/tmux/scripts/session-picker.sh
# Interactive tmux session picker with live pane preview and last-connected time.
#
# Launch via tmux: prefix + S  (see tmux.conf)
# Standalone:     tmux display-popup -E -w 90% -h 85% "$HOME/.config/tmux/scripts/session-picker.sh"
#
# Keys inside the picker:
#   Enter       attach to session
#   Ctrl-n      create new session (auto-named claude-<timestamp>)
#   Ctrl-k      kill selected session
#   Ctrl-d      detach all other clients from selected session
#   q / Esc     quit without attaching

set -euo pipefail

SELF="$(realpath "${BASH_SOURCE[0]}")"

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

# ---------------------------------------------------------------------------
# --list: print session table to stdout (one line per session)
# Called by fzf and by --reload binding
# ---------------------------------------------------------------------------

_list() {
    tmux list-sessions \
        -F "#{session_name}|#{session_last_attached}|#{session_attached}|#{session_windows}" \
        2>/dev/null | \
    while IFS="|" read -r name ts attached windows; do
        local last badge
        last=$(_fmt_time "${ts}")
        if [[ "${attached:-0}" -gt 0 ]]; then
            badge=$'\033[32m●\033[0m LIVE'
        else
            badge="○     "
        fi
        printf "%-24s  %s  %-16s  %sw\n" "${name}" "${badge}" "${last}" "${windows}"
    done
}

# ---------------------------------------------------------------------------
# --preview NAME: render pane content for fzf's preview panel
# ---------------------------------------------------------------------------

_preview() {
    local name="${1}"
    local width
    width=$(tput cols 2>/dev/null || echo 80)

    # Title bar
    local hdr=" ${name} "
    local sides=$(( (width - ${#hdr} - 2) / 2 ))
    [[ $sides -lt 1 ]] && sides=1
    printf '\033[1;34m'
    printf '─%.0s' $(seq 1 "${sides}")
    printf '%s' "${hdr}"
    printf '─%.0s' $(seq 1 "${sides}")
    printf '\033[0m\n'

    # Last-connected time + attached status from live tmux data
    local session_line
    session_line=$(tmux list-sessions \
        -F "#{session_name}|#{session_last_attached}|#{session_attached}" \
        2>/dev/null | grep "^${name}|" | head -1 || true)

    if [[ -n "${session_line}" ]]; then
        local ts att
        IFS="|" read -r _ ts att <<< "${session_line}"
        local last status_txt
        last=$(_fmt_time "${ts}")
        if [[ "${att:-0}" -gt 0 ]]; then
            status_txt=$'\033[32m● currently attached\033[0m'
        else
            status_txt=$'\033[2m○ detached\033[0m'
        fi
        printf ' %s   \033[2mlast connected:\033[0m %s\n\n' "${status_txt}" "${last}"
    fi

    # Live pane content (preserves ANSI color via -e)
    tmux capture-pane -t "${name}" -p -e 2>/dev/null | tail -40 \
        || printf '\033[2m  (no content — session may not have any panes)\033[0m\n'
}

# ---------------------------------------------------------------------------
# --graphical NAME: inline image preview via kitty graphics protocol
# Requires: silicon (brew install silicon) + viu (brew install viu)
# Falls back to text preview if tools are absent.
# ---------------------------------------------------------------------------

_graphical_preview() {
    local name="${1}"
    if ! command -v silicon &>/dev/null || ! command -v viu &>/dev/null; then
        printf '\033[2m  Graphical preview requires: brew install silicon viu\033[0m\n\n'
        _preview "${name}"
        return
    fi
    local tmpfile
    tmpfile=$(mktemp /tmp/tmux-preview-XXXXXX.png)
    tmux capture-pane -t "${name}" -p 2>/dev/null | tail -30 \
        | silicon --no-line-number --no-window-controls \
            --background "#1e1e2e" --theme "Catppuccin-mocha" \
            --output "${tmpfile}" - 2>/dev/null \
        && viu --width "$(tput cols)" "${tmpfile}" 2>/dev/null \
        || _preview "${name}"
    rm -f "${tmpfile}"
}

# ---------------------------------------------------------------------------
# Main picker
# ---------------------------------------------------------------------------

_pick() {
    if ! command -v fzf &>/dev/null; then
        echo "fzf is required. Install with: brew install fzf" >&2
        read -r -p "Press Enter to exit..."
        exit 1
    fi

    local selected
    selected=$("${SELF}" --list | \
        fzf \
            --ansi \
            --reverse \
            --no-sort \
            --border=rounded \
            --border-label=" ❯ tmux sessions " \
            --border-label-pos=3 \
            --prompt="  " \
            --pointer="▶" \
            --info=hidden \
            --header=$'\033[2mEnter:attach  ctrl-n:new  ctrl-k:kill  ctrl-d:detach-others  q:quit\033[0m' \
            --header-first \
            --preview="${SELF} --preview {1}" \
            --preview-window="right:62%:wrap" \
            --bind="ctrl-n:execute-silent(tmux new-session -d -s \"claude-\$(date +%s)\")+reload(${SELF} --list)" \
            --bind="ctrl-k:execute-silent(tmux kill-session -t {1})+reload(${SELF} --list)" \
            --bind="ctrl-d:execute-silent(tmux detach-client -s {1} 2>/dev/null || true)+reload(${SELF} --list)" \
            --bind="q:abort" \
            --bind="esc:abort" \
    ) || exit 0

    [[ -z "${selected}" ]] && exit 0
    local session
    session=$(awk '{print $1}' <<< "${selected}")

    if [[ -n "${TMUX:-}" ]]; then
        tmux switch-client -t "${session}"
    else
        exec tmux attach-session -t "${session}"
    fi
}

# ---------------------------------------------------------------------------
# Dispatch
# ---------------------------------------------------------------------------

case "${1:-}" in
    --list)       _list ;;
    --preview)    _preview "${2}" ;;
    --graphical)  _graphical_preview "${2}" ;;
    *)            _pick ;;
esac
