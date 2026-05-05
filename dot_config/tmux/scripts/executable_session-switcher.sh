#!/usr/bin/env bash

selected=$(tmux list-sessions -F '#S' 2>/dev/null \
  | fzf \
      --print-query \
      --no-preview \
      --reverse \
      --bind "D:execute(tmux kill-session -t {})+reload(tmux list-sessions -F '#S' 2>/dev/null)" \
  | tail -1)

[ -z "$selected" ] && exit 0

tmux has-session -t "$selected" 2>/dev/null || tmux new-session -ds "$selected"
tmux switch-client -t "$selected"
