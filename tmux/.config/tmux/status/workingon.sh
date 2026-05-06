#!/usr/bin/env bash
# Display contents of .workingon at the git root of the current pane's directory.
# Usage: workingon.sh <pane_current_path>

dir="${1:-$PWD}"
[ -d "$dir" ] || exit 0

root=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) || exit 0
file="$root/.workingon"
[ -f "$file" ] || exit 0

content=$(head -n1 "$file" | tr -d '\r' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
[ -z "$content" ] && exit 0

printf "#[fg=#cba6f7,bold]working on: %s#[default]" "$content"
