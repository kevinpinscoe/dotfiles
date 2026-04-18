#!/usr/bin/env bash
script="$HOME/.environment/what_aws_env_am_i.sh"
[ ! -f "$script" ] && exit 0
account=$("$script" 2>/dev/null)
[ -z "$account" ] && exit 0
printf "#[fg=#fab387] %s#[default]" "$account"
