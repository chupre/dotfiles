#!/bin/bash
sleep 1
CURRENT_WORKSPACE=$(i3-msg -t get_workspaces \
  | jq '.[] | select(.focused==true).name' \
  | cut -d"\"" -f2)

i3-msg '[class="Yamusic"] focus; move left; move left; resize grow width 20 px or 20 ppt; workspace '"$CURRENT_WORKSPACE"

