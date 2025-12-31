#!/usr/bin/env bash

current_layout=$(
  defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources |
    awk -F'"' '/KeyboardLayout Name/{print $4; exit}'
)

case "$current_layout" in
"U.S.") label="🇺🇸 US " ;;
"USInternational-PC") label="🌍 US Int " ;;
*) label="$current_layout" ;;
esac

# Always reference the item name explicitly
sketchybar --set keyboard_layout label="$label"
