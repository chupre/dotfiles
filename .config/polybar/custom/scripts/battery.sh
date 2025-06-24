#!/bin/bash

# Paths to battery info
BAT_PATH="/sys/class/power_supply/BAT1"
capacity=$(cat "$BAT_PATH/capacity")
status=$(cat "$BAT_PATH/status")

# Select icon based on capacity
if [ "$capacity" -le 10 ]; then
    icon=""
elif [ "$capacity" -le 30 ]; then
    icon=""
elif [ "$capacity" -le 59 ]; then
    icon=""
elif [ "$capacity" -le 79 ]; then
    icon=""
else
    icon=""
fi

# If charging, append status label
extra=""
if [ "$status" = "Charging" ] || [ "$status" = "Full" ]; then
    extra="󱐋 "
fi

echo "$extra$icon "
