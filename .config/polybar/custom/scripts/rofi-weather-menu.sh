#!/bin/sh

WEATHER_FILE="/tmp/weather.json"
FORECAST_URL="https://yandex.ru/pogoda/ru?lat=55.62017059&lon=38.10562515"

[ ! -f "$WEATHER_FILE" ] && echo "Weather data not available." && exit 1

weather=$(cat "$WEATHER_FILE")

temp=$(echo "$weather" | jq ".main.temp" | cut -d "." -f 1)
feels_like=$(echo "$weather" | jq ".main.feels_like" | cut -d "." -f 1)
humidity=$(echo "$weather" | jq ".main.humidity")
pressure=$(echo "$weather" | jq ".main.pressure")
wind_speed=$(echo "$weather" | jq ".wind.speed")
description=$(echo "$weather" | jq -r ".weather[0].description" | sed 's/.*/\u&/')
city=$(echo "$weather" | jq -r ".name")

choice=$(rofi -dmenu -theme /home/denis/.dotfiles/.config/polybar/custom/scripts/rofi_themes/weather.rasi -p "Weather" -selected-row 7 <<EOF
󱡵 $city
 Temp: $temp°C
 Feels like: $feels_like°C
󰖌 Humidity: $humidity%
  Wind: ${wind_speed} m/s
 Pressure: ${pressure} hPa
 Condition: $description
 Open forecast
EOF
)

if echo "$choice" | grep -q "Open forecast"; then
    zen "$FORECAST_URL" &
fi

