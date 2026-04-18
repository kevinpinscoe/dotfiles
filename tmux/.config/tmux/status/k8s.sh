#!/usr/bin/env bash
context=$(kubectl config current-context 2>/dev/null) || exit 0
cluster=$(echo "$context" | awk -F'/' '{print $2}')
[ -z "$cluster" ] && cluster="$context"
printf "#[fg=#f38ba8]⎈ %s#[default]" "$cluster"
