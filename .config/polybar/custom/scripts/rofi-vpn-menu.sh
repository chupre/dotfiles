#!/bin/bash

CONFIG_SRC="$HOME/.config/sing-box/config.json"
CONFIG_ACTIVE="$HOME/.config/sing-box/active.json"
CACHE_FILE="$HOME/.config/sing-box/vpn_cache.json"
TRIGGER_FILE="$HOME/.config/sing-box/vpn_update_trigger"

theme="/home/denis/.dotfiles/.config/polybar/custom/scripts/rofi_themes/vpn.rasi"

# Map ISO country codes to flag + name
declare -A COUNTRY_MAP=(
    ["NL"]="🇳🇱 Netherlands"
    ["DE"]="🇩🇪 Germany"
    ["SE"]="🇸🇪 Sweden"
    ["FI"]="🇫🇮 Finland"
    ["US"]="🇺🇸 USA"
)

# Read from cache
if [ ! -f "$CACHE_FILE" ]; then
    echo '{"ip":"N/A","country":"N/A","ping":"N/A","status":"Disconnected","ping_results":{}}' > "$CACHE_FILE"
fi

CURRENT_IP=$(jq -r '.ip' "$CACHE_FILE")
CURRENT_COUNTRY=$(jq -r '.country' "$CACHE_FILE")
PING=$(jq -r '.ping' "$CACHE_FILE")
STATUS=$(jq -r '.status' "$CACHE_FILE")
CURRENT_TAG=${COUNTRY_MAP[$CURRENT_COUNTRY]:-"🌐 Unknown"}
[ "$STATUS" = "Connected" ] && STATUS="Connected ($CURRENT_TAG)"

# Extract raw VLESS outbound tags and their server addresses
mapfile -t SERVER_INFO < <(jq -r '.outbounds[] | select(.type=="vless") | .tag + ":" + .server' "$CONFIG_SRC" | sort -u)

# Check if 'auto' group exists
HAS_AUTO=$(jq -r '.outbounds[] | select(.type=="urltest") | .tag' "$CONFIG_SRC" | grep -x "auto")

# Build options for rofi
OPTIONS=()
OPTIONS+=("Status: $STATUS")
OPTIONS+=("IP: $CURRENT_IP")
OPTIONS+=("Ping: $PING")

[ -n "$HAS_AUTO" ] && OPTIONS+=("Connect to ⚡ Fastest (auto)")

for info in "${SERVER_INFO[@]}"; do
    TAG=$(echo "$info" | cut -d':' -f1)
    display="$TAG"
    for code in "${!COUNTRY_MAP[@]}"; do
        if [[ "${COUNTRY_MAP[$code]}" == *"$TAG" ]]; then
            display="${COUNTRY_MAP[$code]}"
            break
        fi
    done
    PING_TIME=$(jq -r ".ping_results.\"$TAG\"" "$CACHE_FILE")
    OPTIONS+=("Connect to $display [$PING_TIME]")
done

OPTIONS+=("Refresh Now")
OPTIONS+=("Disconnect VPN")

# Show rofi menu
CHOICE=$(printf '%s\n' "${OPTIONS[@]}" | rofi -dmenu -theme $theme -p "VPN")

case "$CHOICE" in
    "Refresh Now")
        touch "$TRIGGER_FILE"
        ;;
    "Connect to "*auto*)
        jq '.route.final = "auto"' "$CONFIG_SRC" > "$CONFIG_ACTIVE"
        pkill -f "sing-box run"
        nohup sing-box run -c "$CONFIG_ACTIVE" >/dev/null 2>&1 &
        touch "$TRIGGER_FILE"  # Trigger cache update
        ;;
    "Connect to"*)
        DISPLAYED=$(echo "$CHOICE" | sed 's/Connect to \(.*\) \[.*\]/\1/')
        SERVER=""
        for code in "${!COUNTRY_MAP[@]}"; do
            if [[ "${COUNTRY_MAP[$code]}" == "$DISPLAYED" ]]; then
                SERVER="${COUNTRY_MAP[$code]##* }"  # Extract "Germany" from "🇩🇪 Germany"
                break
            fi
        done
        SERVER=${SERVER:-$DISPLAYED}  # Fallback
        jq --arg target "$SERVER" '.route.final = $target' "$CONFIG_SRC" > "$CONFIG_ACTIVE"
        pkill -f "sing-box run"
        nohup sing-box run -c "$CONFIG_ACTIVE" >/dev/null 2>&1 &
        touch "$TRIGGER_FILE"  # Trigger cache update
        ;;
    "Disconnect VPN")
        pkill -f "sing-box run"
        touch "$TRIGGER_FILE"  # Trigger cache update
        ;;
esac
