#!/usr/bin/env bash
profile_file="$HOME/.aws/active_profile"
if [[ -f "$profile_file" ]]; then
    profile=$(cat "$profile_file")
elif [[ -n "${AWS_PROFILE:-}" ]]; then
    profile="$AWS_PROFILE"
else
    script="$HOME/.environment/what_aws_env_am_i.sh"
    [[ -f "$script" ]] || exit 0
    profile=$("$script" 2>/dev/null)
fi
[[ -z "$profile" || "$profile" == "none" ]] && exit 0
printf "#[fg=#fab387] %s#[default]" "$profile"
