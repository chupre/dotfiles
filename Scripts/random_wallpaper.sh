#!/bin/bash

# Base directory containing subfolders of images
BASE_DIR="/home/denis/Pictures/walls"

# Pick a random subdirectory
RANDOM_DIR=$(find "$BASE_DIR" -mindepth 1 -maxdepth 1 -type d | shuf -n 1)

# Pick a random image file from the selected directory
RANDOM_IMAGE=$(find "$RANDOM_DIR" -type f | shuf -n 1)

# Set the wallpaper using gsettings
gsettings set org.cinnamon.desktop.background picture-uri "file://$RANDOM_IMAGE"
