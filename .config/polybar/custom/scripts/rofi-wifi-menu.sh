#!/usr/bin/env bash

# Function to get current SSID without forcing a rescan
get_current_ssid() {
    local active_conn=$(nmcli -t -f NAME,DEVICE connection show --active | grep ":wlp1s0" | cut -d':' -f1)
    if [[ -n "$active_conn" ]]; then
        nmcli -t -f connection.id connection show "$active_conn" | cut -d':' -f2 | sed 's/^Auto //'
    else
        echo ""
    fi
}

# Function to get Wi-Fi status
get_wifi_status() {
    nmcli -fields WIFI g | grep -q "enabled" && echo "enabled" || echo "disabled"
}

# Function to get Wi-Fi list without forcing a rescan
get_wifi_list() {
    nmcli --fields "SECURITY,SSID" device wifi list --rescan no | sed 1d | sed 's/  */ /g' | sed -E "s/WPA*.?\S/ /g" | sed "s/^--/ /g" | sed "s/  //g" | sed "/--/d"
}

# Function to force a Wi-Fi rescan
rescan_wifi() {
    nmcli device wifi list --rescan yes > /dev/null
}

# Main logic
current_ssid=$(get_current_ssid)
echo $current_ssid
wifi_status=$(get_wifi_status)
raw_list=$(get_wifi_list)

# Build Wi-Fi list with connection indicator
wifi_list=""
while IFS= read -r line; do
    ssid=$(echo "$line" | awk '{print $NF}')
    if [[ "$ssid" == "$current_ssid" ]]; then
        wifi_list+="$line "$'\n'
    else
        wifi_list+="$line"$'\n'
    fi
done <<< "$raw_list"

wifi_list=$(echo "$wifi_list" | sed '/^$/d')

# Set toggle and rescan options based on Wi-Fi status
if [[ "$wifi_status" == "enabled" ]]; then
    toggle="󰖪  Disable Wi-Fi"
    rescan_option="󰑓 Refresh Scan"
else
    toggle="󰖩  Enable Wi-Fi"
    rescan_option=""
fi

# Use rofi to select Wi-Fi network or action
chosen_network=$(echo -e "$toggle\n$rescan_option\n$wifi_list" | uniq -u | rofi -dmenu \
    -i -selected-row 1 -p "Wi-Fi" \
    -theme /home/denis/.dotfiles/.config/polybar/custom/scripts/rofi_themes/bluetooth.rasi)
chosen_id=$(echo "${chosen_network:3}" | sed 's/$//' | sed 's/ *$//')

if [[ -z "$chosen_network" ]]; then
    exit
elif [[ "$chosen_network" == "󰖩  Enable Wi-Fi" ]]; then
    nmcli radio wifi on
elif [[ "$chosen_network" == "󰖪  Disable Wi-Fi" ]]; then
    nmcli radio wifi off
elif [[ "$chosen_network" == "🔄 Rescan Wi-Fi" ]]; then
    rescan_wifi
    exec "$0"
else
    success_message="You are now connected to the Wi-Fi network \"$chosen_id\"."
    saved_connections=$(nmcli -g NAME connection)
    if [[ "$saved_connections" =~ (^|[[:space:]])"$chosen_id"($|[[:space:]]) ]]; then
        nmcli connection up id "$chosen_id" | grep "successfully" && notify-send "Connection Established" "$success_message"
    else
        if [[ "$chosen_network" =~ "" ]]; then
            wifi_password=$(rofi -dmenu -p "Password: ")
        fi
        nmcli device wifi connect "$chosen_id" password "$wifi_password" | grep "successfully" && notify-send "Connection Established" "$success_message"
    fi
fi
