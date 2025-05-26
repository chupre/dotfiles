#!/usr/bin/env bash
#             __ _       _     _            _              _   _
#  _ __ ___  / _(_)     | |__ | |_   _  ___| |_ ___   ___ | |_| |__
# | '__/ _ \| |_| |_____| '_ \| | | | |/ _ \ __/ _ \ / _ \| __| '_ \
# | | | (_) |  _| |_____| |_) | | |_| |  __/ || (_) | (_) | |_| | | |
# |_|  \___/|_| |_|     |_.__/|_|\__,_|\___|\__\___/ \___/ \__|_| |_|
#
# Author: Nick Clyde (clydedroid)
# Updated by ChatGPT to include battery level for connected devices

goback="Back 󰌍"
on="ON"
off="OFF"

# Check if bluetooth is on
power_on() {
    bluetoothctl show | grep -q "Powered: yes"
}

toggle_power() {
    if power_on; then
        bluetoothctl power off
        show_menu
    else
        rfkill list bluetooth | grep -q 'blocked: yes' && rfkill unblock bluetooth && sleep 3
        bluetoothctl power on
        show_menu
    fi
}

scan_on() {
    if bluetoothctl show | grep -q "Discovering: yes"; then
        echo "Scan: $on"
        return 0
    else
        echo "Scan: $off"
        return 1
    fi
}

toggle_scan() {
    if scan_on; then
        kill "$(pgrep -f "bluetoothctl --timeout 5 scan on")" 2>/dev/null
        bluetoothctl scan off
        show_menu
    else
        bluetoothctl --timeout 5 scan on
        echo "Scanning..."
        show_menu
    fi
}

pairable_on() {
    bluetoothctl show | grep -q "Pairable: yes" && echo "Pairable: $on" && return 0
    echo "Pairable: $off"; return 1
}

toggle_pairable() {
    bluetoothctl pairable $(pairable_on && echo off || echo on)
    show_menu
}

discoverable_on() {
    bluetoothctl show | grep -q "Discoverable: yes" && echo "Discoverable: $on" && return 0
    echo "Discoverable: $off"; return 1
}

toggle_discoverable() {
    bluetoothctl discoverable $(discoverable_on && echo off || echo on)
    show_menu
}

device_connected() {
    bluetoothctl info "$1" | grep -q "Connected: yes"
}

device_paired() {
    bluetoothctl info "$1" | grep -q "Paired: yes" && echo "Paired: yes" && return 0
    echo "Paired: no"; return 1
}

device_trusted() {
    bluetoothctl info "$1" | grep -q "Trusted: yes" && echo "Trusted: yes" && return 0
    echo "Trusted: no"; return 1
}

toggle_connection() {
    if device_connected "$1"; then
        bluetoothctl disconnect "$1"
    else
        bluetoothctl connect "$1"
    fi
    device_menu "$device"
}

toggle_paired() {
    if device_paired "$1"; then
        bluetoothctl remove "$1"
    else
        bluetoothctl pair "$1"
    fi
    device_menu "$device"
}

toggle_trust() {
    if device_trusted "$1"; then
        bluetoothctl untrust "$1"
    else
        bluetoothctl trust "$1"
    fi
    device_menu "$device"
}

print_status() {
    if power_on; then
        printf ''
        mapfile -t paired_devices < <(bluetoothctl devices Paired | cut -d ' ' -f 2)
        for device in "${paired_devices[@]}"; do
            if device_connected "$device"; then
                alias=$(bluetoothctl info "$device" | grep "Alias" | cut -d ' ' -f 2-)
                printf " %s" "$alias"
            fi
        done
        printf "\n"
    else
        echo ""
    fi
}

# 🔋 Battery level lookup via upower
get_battery_level() {
    mac="$1"
    upower_id=$(upower -d | grep -i "$mac" | awk '{print $1}')
    if [ -n "$upower_id" ]; then
        percentage=$(upower -d | grep -A 10 "$upower_id" | grep percentage | awk '{print $2}' | tr -d '%')
        echo "${percentage}%"
    else
        echo ""
    fi
}

device_menu() {
    device=$1
    device_name=$(echo "$device" | cut -d ' ' -f 3-)
    mac=$(echo "$device" | cut -d ' ' -f 2)

    connected="Connected: $(device_connected "$mac" && echo yes || echo no)"
    paired=$(device_paired "$mac")
    trusted=$(device_trusted "$mac")

    options="$connected\n$paired\n$trusted\n$goback\nExit 󰈆"
    chosen="$(echo -e "$options" | $rofi_command "$device_name")"

    case "$chosen" in
        "$connected") toggle_connection "$mac" ;;
        "$paired") toggle_paired "$mac" ;;
        "$trusted") toggle_trust "$mac" ;;
        "$goback") show_menu ;;
    esac
}

show_menu() {
    if power_on; then
        power="Power: $on"
        mapfile -t raw_devices < <(bluetoothctl devices | grep Device)

        devices=""
        for dev in "${raw_devices[@]}"; do
            mac=$(echo "$dev" | cut -d ' ' -f 2)
            name=$(echo "$dev" | cut -d ' ' -f 3-)
            if device_connected "$mac"; then
                icon="󰂯"
                battery=$(get_battery_level "$mac")
                [ -n "$battery" ] && name="$name ($battery)"
            else
                icon="󰂲"
            fi
            devices+="$name $icon"$'\n'
        done
        devices="${devices%$'\n'}"

        scan=$(scan_on)
        pairable=$(pairable_on)
        discoverable=$(discoverable_on)

        options="$devices\n$power\n$scan\n$pairable\n$discoverable\nExit"
    else
        power="Power: $off"
        options="$power\nExit"
    fi

    chosen="$(echo -e "$options" | $rofi_command "󰂯")"

    case "$chosen" in
        "$power") toggle_power ;;
        "$scan") toggle_scan ;;
        "$discoverable") toggle_discoverable ;;
        "$pairable") toggle_pairable ;;
        *)
            chosen_clean=$(echo "$chosen" | sed -E 's/ \([0-9]+%\)//' | sed 's/ [󰂯󰂲]$//')
            device=$(bluetoothctl devices | grep " $chosen_clean$")
            [ -n "$device" ] && device_menu "$device"
            ;;
    esac
}

rofi_command="rofi -dmenu -theme /home/denis/.dotfiles/.config/polybar/custom/scripts/rofi_themes/bluetooth.rasi $* -p Bluetooth"

case "$1" in
    --status) print_status ;;
    *) show_menu ;;
esac

