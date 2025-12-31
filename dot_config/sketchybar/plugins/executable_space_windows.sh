#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

AEROSPACE_FOCUSED_MONITOR=$(aerospace list-monitors --focused | awk '{print $1}')
AEROSAPCE_WORKSPACE_FOCUSED_MONITOR=$(aerospace list-workspaces --monitor focused --empty no)
AEROSPACE_EMPTY_WORKESPACE=$(aerospace list-workspaces --monitor focused --empty)

reload_workspace_icon() {
  apps=$(aerospace list-windows --workspace "$@" | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')

  sketchybar --animate sin 10 --set space.$@ label=""
}

if [ "$SENDER" = "aerospace_workspace_change" ]; then

  reload_workspace_icon "$AEROSPACE_PREV_WORKSPACE"
  reload_workspace_icon "$AEROSPACE_FOCUSED_WORKSPACE"

  #sketchybar --animate sin 10 --set space.$space label="$icon_strip"

  # current workspace space border color
  sketchybar --set space.$AEROSPACE_FOCUSED_WORKSPACE icon.highlight=true \
    label.highlight=true \
    background.border_color=$BLUE \
    background.color=$BACKGROUND_2

  # prev workspace space border color
  sketchybar --set space.$AEROSPACE_PREV_WORKSPACE icon.highlight=false \
    label.highlight=false \
    background.border_color=$BACKGROUND_2 \
    background.color=$BG1

  for i in $AEROSAPCE_WORKSPACE_FOCUSED_MONITOR; do
    sketchybar --set space.$i display=$AEROSPACE_FOCUSED_MONITOR
  done

  for i in $AEROSPACE_EMPTY_WORKESPACE; do
    sketchybar --set space.$i display=0
  done

  sketchybar --set space.$AEROSPACE_FOCUSED_WORKSPACE display=$AEROSPACE_FOCUSED_MONITOR

fi
