#!/bin/bash

# Get current SSID
ssid=$(iwgetid -r)

# Get signal strength (0-100)
signal=$(awk 'NR==3 {printf("%.0f\n", $3*10/7)}' /proc/net/wireless)

# Choose icon
if [ -z "$ssid" ]; then
    icon="󰤮"
else
    if (( signal > 85 )); then
        icon="󰤨"
    elif (( signal > 50 )); then
        icon="󰤥"
    elif (( signal > 25 )); then
        icon="󰤟"
    else
        icon="󰤯"
    fi
fi

echo "$icon"
