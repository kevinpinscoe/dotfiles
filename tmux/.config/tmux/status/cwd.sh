#!/usr/bin/env bash
dir="${1:-$PWD}"
home=$(eval echo "~")
short=$(echo "$dir" | sed "s|^$home|~|")
printf "#[fg=#a6e3a1]%s#[default]" "$short"
