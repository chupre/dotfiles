#!/bin/bash

# Base directory containing subfolders of images
BASE_DIR="/home/denis/Pictures/walls"

# Pick a random subdirectory
RANDOM_DIR=$(find "$BASE_DIR" -mindepth 1 -maxdepth 1 -type d | shuf -n 1)

# Pick a random image file from the selected directory
RANDOM_IMAGE=$(find "$RANDOM_DIR" -type f | shuf -n 1)

# Set the wallpaper using gsettings
/usr/bin/feh --bg-scale $RANDOM_IMAGE
echo $RANDOM_IMAGE > /home/denis/Scripts/current_wallpaper_i3.txt
wal -s -i $RANDOM_IMAGE
/home/denis/Scripts/pywal2alacritty.sh
/home/denis/Scripts/wal2polybar.sh
