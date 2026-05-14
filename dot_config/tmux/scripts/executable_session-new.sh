#!/usr/bin/env bash

name=$(gum input --no-show-help --header "New session")
[ -z "$name" ] && exit 0

tmux new-session -ds "$name" 2>/dev/null
tmux switch-client -t "$name"
