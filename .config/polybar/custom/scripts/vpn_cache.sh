#!/bin/bash

CACHE_FILE="$HOME/.config/sing-box/vpn_cache.json"
TRIGGER_FILE="$HOME/.config/sing-box/vpn_update_trigger"
CONFIG_SRC="$HOME/.config/sing-box/config.json"
INTERVAL=30  # Update interval in seconds
PING_COUNT=3  # Number of pings for averaging

# Ensure cache directory exists
mkdir -p "$(dirname "$CACHE_FILE")"

# Initialize cache if it doesn't exist
if [ ! -f "$CACHE_FILE" ]; then
    echo '{"ip":"N/A","country":"N/A","ping":"N/A","status":"Disconnected","ping_results":{}}' > "$CACHE_FILE"
fi

# Function to measure latency (average of multiple pings or TCP fallback, truncated to integer)
measure_latency() {
    local server=$1
    local tag=$2
    # Try ICMP ping first
    local ping_output=$(ping -c "$PING_COUNT" -w 3 "$server" 2>/dev/null)
    if echo "$ping_output" | grep -q "time="; then
        local avg_time=$(echo "$ping_output" | grep "rtt min/avg/max" | awk -F'/' '{print $5}' | awk '{print int($1)}')
        [ -n "$avg_time" ] && echo "$avg_time ms" || echo "N/A"
    else
        # Fallback to TCP ping (port 443, common for VPN servers)
        local tcp_time=$( (time -p nc -w 2 -z "$server" 443) 2>&1 | grep real | awk '{print $2}' | awk '{print int($1*1000)}')
        if [ -n "$tcp_time" ] && [ "$tcp_time" != "0" ]; then
            echo "${tcp_time} ms"
        else
            echo "N/A"
        fi
    fi
}

while true; do
    # Check for trigger file to force update
    if [ -f "$TRIGGER_FILE" ]; then
        rm -f "$TRIGGER_FILE"
        FORCE_UPDATE=1
    else
        FORCE_UPDATE=0
    fi

    # Only update if forced or interval has passed
    if [ $FORCE_UPDATE -eq 1 ] || [ ! -f "$CACHE_FILE" ] || [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE"))) -ge $INTERVAL ]; then
        VPN_PID=$(pgrep -f "sing-box run")
        IPINFO=$(curl -s ipinfo.io || echo '{}')
        CURRENT_COUNTRY=$(echo "$IPINFO" | jq -r '.country // "N/A"')
        CURRENT_IP=$(echo "$IPINFO" | jq -r '.ip // "N/A"')
        PING=$(measure_latency "$CURRENT_IP" "current" || echo "N/A")
        STATUS="Disconnected"
        [ -n "$VPN_PID" ] && STATUS="Connected"

        # Get ping results for servers
        PING_RESULTS={}
        mapfile -t SERVER_INFO < <(jq -r '.outbounds[] | select(.type=="vless") | .tag + ":" + .server' "$CONFIG_SRC" | sort -u)
        for info in "${SERVER_INFO[@]}"; do
            TAG=$(echo "$info" | cut -d':' -f1)
            SERVER_ADDR=$(echo "$info" | cut -d':' -f2)
            PING_TIME=$(measure_latency "$SERVER_ADDR" "$TAG")
            PING_RESULTS=$(jq --arg tag "$TAG" --arg ping "$PING_TIME" '. + {($tag): $ping}' <<< "$PING_RESULTS")
        done

        # Update cache file
        jq --arg ip "$CURRENT_IP" \
           --arg country "$CURRENT_COUNTRY" \
           --arg ping "$PING" \
           --arg status "$STATUS" \
           --argjson pings "$PING_RESULTS" \
           '.ip=$ip | .country=$country | .ping=$ping | .status=$status | .ping_results=$pings' \
           "$CACHE_FILE" > "${CACHE_FILE}.tmp" && mv "${CACHE_FILE}.tmp" "$CACHE_FILE"
    fi

    sleep 1
done
