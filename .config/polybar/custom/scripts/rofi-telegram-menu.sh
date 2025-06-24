#!/bin/bash

# Check if dunst is running
if pgrep -x dunst >/dev/null; then
    NOTIFY_OPTION="Disable Notifications"
else
    NOTIFY_OPTION="Enable Notifications"
fi

# Rofi menu options
OPTIONS="Open Telegram\nQuit Telegram\n$NOTIFY_OPTION"
CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -p "Telegram Menu" -theme /home/denis/.dotfiles/.config/polybar/custom/scripts/rofi_themes/telegram.rasi)

case "$CHOICE" in
    "Open Telegram")
        pkill Telegram 2>/dev/null
        nohup /home/denis/Apps/Telegram/Telegram >/dev/null 2>&1 &
        ;;
    "Quit Telegram")
        pkill Telegram
        ;;
    "Enable Notifications")
        nohup dunst >/dev/null 2>&1 &
        ;;
    "Disable Notifications")
        pkill dunst
        ;;
    *)
        exit 1
        ;;
esac

