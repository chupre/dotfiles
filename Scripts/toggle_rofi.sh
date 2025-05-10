#!/bin/bash
if pgrep -x rofi > /dev/null; then
    pkill rofi
else
    rofi -font "SF Pro Rounded 12" -no-lazy-grab -show-icons -show drun
fi
