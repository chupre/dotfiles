#!/bin/bash

STATE_FILE="/tmp/polybar-vpn-info-toggle"
[ ! -f "$STATE_FILE" ] && echo "icon" > "$STATE_FILE"

SINGBOX_BIN="sing-box"
CONFIG_FILE="$HOME/.config/sing-box/config.json"
PIDFILE="/tmp/singbox-vpn.pid"
TRIGGER_FILE="$HOME/.config/sing-box/vpn_update_trigger"

icon_on="󰞀"
icon_off="󰦞"

# Map country codes to flag + name
declare -A country_map=(
    ["NL"]="Netherlands"
    ["DE"]="Germany"
    ["SE"]="Sweden"
    ["FI"]="Finland"
    ["US"]="USA"
)

is_vpn_active() {
    pgrep -x "$SINGBOX_BIN" > /dev/null
}

start_vpn() {
    nohup "$SINGBOX_BIN" run -c "$CONFIG_FILE" > /dev/null 2>&1 &
    echo $! > "$PIDFILE"
}

stop_vpn() {
    pkill -x "$SINGBOX_BIN"
    [ -f "$PIDFILE" ] && rm "$PIDFILE"
}

toggle_vpn() {
    if is_vpn_active; then
        stop_vpn
    else
        start_vpn
    fi
    
    touch "$TRIGGER_FILE"
}

case "$1" in
    toggle)
        toggle_vpn
        ;;
    *)
        state=$(cat "$STATE_FILE")
        if is_vpn_active; then
            icon="$icon_on"
            if [ "$state" = "full" ]; then
                info=$(get_country_info)
                echo "$icon  $info"
            else
                echo "$icon"
            fi
        else
            echo "$icon_off"
        fi
        ;;
esac

