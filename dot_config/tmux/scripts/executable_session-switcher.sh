#!/usr/bin/env bash

sessions=$(tmux list-sessions -F '#S' 2>/dev/null)
[ -z "$sessions" ] && exit 0

selected=$(echo "$sessions" | gum choose --no-show-help --header "Session")
[ -z "$selected" ] && exit 0

tmux switch-client -t "$selected"
