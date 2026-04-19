#!/usr/bin/env bash
[ -z "$WORKINGON" ] && exit 0
printf "#[fg=#cba6f7,bold]working on: %s#[default]" "$WORKINGON"
