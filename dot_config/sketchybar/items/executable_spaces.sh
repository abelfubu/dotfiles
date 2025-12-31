#!/bin/sh

# Destroy space on right click, focus space on left click.
# New space by left clicking separator (>)

sketchybar --add event aerospace_workspace_change

for m in $(aerospace list-monitors | awk '{print $1}'); do
  for i in $(aerospace list-workspaces --monitor $m); do
    sid=$i
    space=(
      space="$sid"
      icon="$sid"
      icon.highlight_color=$BLUE
      icon.padding_left=9
      icon.padding_right=4
      display=$m
      padding_left=2
      padding_right=2
      # label.padding_right=20
      label.color=$GREY
      label.highlight_color=$WHITE
      label.font="sketchybar-app-font:Regular:16.0"
      label.y_offset=-1
      background.color=$BG1
      background.border_color=$BACKGROUND_2
      script="$PLUGIN_DIR/space.sh"
    )

    sketchybar --add space space.$sid left \
               --set space.$sid "${space[@]}" \
               --subscribe space.$sid mouse.clicked

    sketchybar --set space.$sid label=""
  done

  for i in $(aerospace list-workspaces --monitor $m --empty); do
    sketchybar --set space.$i display=0
  done
  
done


space_creator=(
  icon=
  icon.font="$FONT:Heavy:16.0"
  padding_left=10
  padding_right=8
  label.drawing=off
  display=active
  #click_script='yabai -m space --create'
  script="$PLUGIN_DIR/space_windows.sh"
  #script="$PLUGIN_DIR/aerospace.sh"
  icon.color=$WHITE
)

sketchybar --add item space_creator left               \
           --set space_creator "${space_creator[@]}"   \
           --subscribe space_creator aerospace_workspace_change
