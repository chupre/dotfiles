#!/bin/bash

# Temp file to store offset
OFFSET_FILE="/tmp/rofi_calendar_offset"
OFFSET=$(cat "$OFFSET_FILE" 2>/dev/null || echo 0)

# Update offset based on user action
if [[ "$1" == "next" ]]; then
    OFFSET=$((OFFSET + 1))
elif [[ "$1" == "prev" ]]; then
    OFFSET=$((OFFSET - 1))
fi

# Save updated offset
echo "$OFFSET" > "$OFFSET_FILE"

# Get target date
TARGET_DATE=$(date --date="$OFFSET month" +%Y-%m-01)
TARGET_YEAR=$(date --date="$TARGET_DATE" +%Y)
TARGET_MONTH=$(date --date="$TARGET_DATE" +%m)

# Today's info
TODAY_YEAR=$(date +%Y)
TODAY_MONTH=$(date +%m)
TODAY_DAY=$(date +%-d)

# Generate calendar
CAL=$(ncal -b -h -M -d "$TARGET_DATE")

# Highlight today's day if in current month
if [[ "$TARGET_YEAR" == "$TODAY_YEAR" && "$TARGET_MONTH" == "$TODAY_MONTH" ]]; then
    CAL=$(echo "$CAL" | sed -E "s/(^|[^0-9])($TODAY_DAY)([^0-9]|$)/\1<span foreground='#0860f2e6'><b>\2<\/b><\/span>\3/g")
fi

# Build menu
MENU=$(echo -e "$CAL\n▶ Next Month\n◀ Previous Month")

# Count calendar lines
CAL_LINES=$(echo "$CAL" | wc -l)

# Show Rofi with default selection on "Next Month"
CHOICE=$(echo -e "$MENU" | rofi -dmenu -markup-rows -theme /home/denis/.dotfiles/.config/polybar/custom/scripts/rofi_themes/calendar.rasi -p "Calendar" -selected-row "$CAL_LINES")

# Handle selection
case "$CHOICE" in
    "◀ Previous Month") "$0" prev ;;
    "▶ Next Month") "$0" next ;;
esac

# Reset offset if user selects nothing
if [[ -z "$CHOICE" ]]; then
    echo 0 > "$OFFSET_FILE"
fi
