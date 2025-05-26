#!/bin/sh

WEATHER_FILE="/tmp/weather.json"

[ ! -f "$WEATHER_FILE" ] && echo "Weather data not available." && exit 1

weather=$(cat "$WEATHER_FILE")

temp=$(echo "$weather" | jq ".main.temp" | cut -d "." -f 1)
feels_like=$(echo "$weather" | jq ".main.feels_like" | cut -d "." -f 1)
humidity=$(echo "$weather" | jq ".main.humidity")
pressure=$(echo "$weather" | jq ".main.pressure")
wind_speed=$(echo "$weather" | jq ".wind.speed")
description=$(echo "$weather" | jq -r ".weather[0].description" | sed 's/.*/\u&/')
city=$(echo "$weather" | jq -r ".name")

rofi -dmenu -theme /home/denis/.dotfiles/.config/polybar/custom/scripts/rofi_themes/weather.rasi -p "Weather" <<EOF
󱡵 $city
 Temp: $temp°C
 Feels like: $feels_like°C
󰖌 Humidity: $humidity%
  Wind: ${wind_speed} m/s
 Pressure: ${pressure} hPa
 Condition: $description
EOF

