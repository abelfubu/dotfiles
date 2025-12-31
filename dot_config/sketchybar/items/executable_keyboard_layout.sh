#!/usr/bin/env bash

sketchybar --add event keyboard_change 'AppleSelectedInputSourcesChangedNotification'

sketchybar --add item keyboard_layout right \
  --set keyboard_layout script="$PLUGIN_DIR/keyboard_layout.sh" \
  --subscribe keyboard_layout keyboard_change
