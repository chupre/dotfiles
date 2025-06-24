#!/bin/bash

# Only check these players in priority order
players="yamusic-tui"
max_length=50

for player in $players; do
    status=$(playerctl --player=$player status 2>/dev/null)
    if [ "$status" = "Playing" ] || [ "$status" = "Paused" ]; then
        artist=$(playerctl --player=$player metadata artist 2>/dev/null)
        title=$(playerctl --player=$player metadata title 2>/dev/null)

        output="$artist - $title"
        icon=""
        [ "$status" = "Paused" ] && icon=""

        # Truncate if too long
        if [ ${#output} -gt $max_length ]; then
            output="${output:0:$((max_length - 1))}…"
        fi

        echo "$icon $output"
        exit 0
    fi
done

# Default icon if nothing is playing or no supported player
echo ""

