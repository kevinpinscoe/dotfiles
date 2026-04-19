#!/usr/bin/env bash
dir="${1:-$PWD}"
branch=$(git -C "$dir" symbolic-ref --short HEAD 2>/dev/null) || exit 0
dirty=$(git -C "$dir" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
if [ "$dirty" -gt 0 ]; then
    printf "#[fg=#f38ba8] %s ✗#[default]" "$branch"
else
    printf "#[fg=#a6e3a1] %s ✓#[default]" "$branch"
fi
