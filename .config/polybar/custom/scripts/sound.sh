#!/bin/bash

# Set your volume control command (pamixer preferred)
HAS_PAMIXER=$(command -v pamixer)
if [ -n "$HAS_PAMIXER" ]; then
    GET_VOL="pamixer --get-volume"
    IS_MUTED="pamixer --get-mute"
    VOL_UP="pamixer -i 5"
    VOL_DOWN="pamixer -d 5"
else
    GET_VOL="amixer get Master | grep -o '[0-9]*%' | head -1 | tr -d '%'"
    IS_MUTED="amixer get Master | grep -q '\\[off\\]' && echo muted || echo unmuted"
    VOL_UP="amixer -q set Master 5%+"
    VOL_DOWN="amixer -q set Master 5%-"
fi

icon_muted=""
icon_low=""
icon_med=""
icon_high=""

case "$1" in
    up)
        eval "$VOL_UP"
        ;;
    down)
        eval "$VOL_DOWN"
        ;;
    *)
        volume=$(eval "$GET_VOL")
        muted=$(eval "$IS_MUTED")

        if [ "$muted" = "true" ] || [ "$muted" = "muted" ]; then
            icon=$icon_muted
            volume="Muted"
        else
            if [ "$volume" -ge 70 ]; then
                icon=$icon_high
            elif [ "$volume" -ge 30 ]; then
                icon=$icon_med
            else
                icon=$icon_low
            fi
        fi

        echo "$icon"
        ;;
esac

