#!/usr/bin/env bash
dir="${1:-$PWD}"
short=$(echo "$dir" | sed "s|^$HOME|~|")
printf "#[fg=#a6e3a1]%s#[default]" "$short"
