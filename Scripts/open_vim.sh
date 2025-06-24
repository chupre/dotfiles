#!/bin/bash

# Get the focused window
focused_window=$(xdotool getactivewindow)
window_pid=$(xdotool getwindowpid $focused_window)
window_name=$(ps -p $window_pid -o command | tail -1)

# Check if the focused window is Alacritty
if [[ "$window_name" =~ "alacritty" ]]; then
    xdotool type --window "$focused_window" "vim ."
    xdotool key --window "$focused_window" Return
else
    echo "$window_name"
    exit 1
fi

