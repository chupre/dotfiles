#!/bin/env sh

BASEDIR=$(dirname "$0")

DEVICE_COUNT=$(pw-cli list-objects | grep node.name | grep output | wc -l)
LINES=$((DEVICE_COUNT + 1))
sed -i '/listview\s*{/,/}/s/^\(\s*lines:\s*\)[0-9]\+;/\1'"$LINES"';/' "/home/denis/.dotfiles/.config/polybar/custom/scripts/rofi_themes/volume.rasi"

# Run Rofi and capture exit code
rofi -theme /home/denis/.dotfiles/.config/polybar/custom/scripts/rofi_themes/volume.rasi \
  -kb-custom-16 "Ctrl+equal" \
  -kb-custom-17 "Alt+m" \
  -kb-custom-18 "minus,underscore" \
  -kb-custom-19 "equal,plus" \
  -show rofi-sink-mixer \
  -modi "rofi-sink-mixer:$BASEDIR/rofi-mixer.py --type sink,rofi-sink-mixer:$BASEDIR/rofi-mixer.py --type app,rofi-source-mixer:$BASEDIR/rofi-mixer.py --type source" "$@"
