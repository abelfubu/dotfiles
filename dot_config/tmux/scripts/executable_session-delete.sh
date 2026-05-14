#!/usr/bin/env bash

sessions=$(tmux list-sessions -F '#S' 2>/dev/null)
[ -z "$sessions" ] && exit 0

selected=$(echo "$sessions" | gum choose --no-show-help --header "Delete session")
[ -z "$selected" ] && exit 0

current=$(tmux display-message -p '#S')

if [ "$selected" = "$current" ]; then
  next=$(tmux list-sessions -F '#S' 2>/dev/null | grep -v "^${selected}$" | head -1)
  [ -n "$next" ] && tmux switch-client -t "$next"
fi

tmux kill-session -t "$selected"
