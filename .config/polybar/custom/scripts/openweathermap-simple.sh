#!/bin/sh

WEATHER_FILE="/tmp/weather.json"

get_icon() {
    case $1 in
        01d) icon="";;
        01n) icon="";;
        02d) icon="";;
        02n) icon="";;
        03*) icon="";;
        04*) icon="";;
        09d) icon="";;
        09n) icon="";;
        10d) icon="";;
        10n) icon="";;
        11d) icon="";;
        11n) icon="";;
        13d) icon="";;
        13n) icon="";;
        50d) icon="";;
        50n) icon="";;
        *) icon="";
    esac
    echo "$icon"
}

KEY="2ab04c7e78ecf214da257f4f8a7e0a0e"
CITY="557140"
UNITS="metric"
SYMBOL="°"
API="https://api.openweathermap.org/data/2.5"

# Get weather
if [ -n "$CITY" ]; then
    if [ "$CITY" -eq "$CITY" ] 2>/dev/null; then
        CITY_PARAM="id=$CITY"
    else
        CITY_PARAM="q=$CITY"
    fi

    weather=$(curl -sf "$API/weather?appid=$KEY&$CITY_PARAM&units=$UNITS")
else
    location=$(curl -sf "https://location.services.mozilla.com/v1/geolocate?key=geoclue")
    if [ -n "$location" ]; then
        lat="$(echo "$location" | jq '.location.lat')"
        lon="$(echo "$location" | jq '.location.lng')"
        weather=$(curl -sf "$API/weather?appid=$KEY&lat=$lat&lon=$lon&units=$UNITS")
    fi
fi

# Output + save
if [ -n "$weather" ]; then
    echo "$weather" > "$WEATHER_FILE"
    temp=$(echo "$weather" | jq ".main.temp" | cut -d "." -f 1)
    icon=$(get_icon "$(echo "$weather" | jq -r ".weather[0].icon")")
    echo "$icon"
fi

