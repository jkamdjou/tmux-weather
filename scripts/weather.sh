#!/usr/bin/env bash

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CWD/tmux.sh"

cache_file=~/.tmux-weather
cache_ttl=900
DARKSKY_API_KEY=$(cat ~/.config/tmux-weather/key)

weather() {
  if [[ -f "$cache_file" ]]; then
    local NOW=$(date +%s)
    local MOD=$(date -r "$cache_file" +%s)
    if [[ $(( $NOW - $MOD )) -gt $cache_ttl ]]; then
      rm "$cache_file"
    fi
  fi

  if [[ ! -f "$cache_file" ]]; then
    GEO=$(curl -s https://ipinfo.io | jq -r '.loc')
    URL="https://api.darksky.net/forecast/$DARKSKY_API_KEY/$GEO"
    echo "here"
    read ICON_STR DEGREES <<< $(curl -s $URL | jq -r '.currently | .icon + " " + "\( .apparentTemperature )"')
    case "$ICON_STR" in
      clear-day)            ICON="☀";;
      clear-night)          ICON="☀";;
      rain)                 ICON="☂";;
      snow)                 ICON="☂";;
      sleet)                ICON="☂";;
      wind)                 ICON="☁";;
      fog)                  ICON="☁";;
      cloudy)               ICON="☁";;
      partly-cloudy-day)    ICON="☁";;
      partly-cloudy-night)  ICON="☁";;
      hail)                 ICON="☂";;
      thunderstorm)         ICON="☂";;
      tornado)              ICON="☂";;
      *)                    ICON="";;
    esac
    local WEATHER="${DEGREES}°"
    [[ -n "$ICON" ]] && WEATHER="$WEATHER $ICON "
    echo "${WEATHER}" >"$cache_file"
  fi
  cat "$cache_file"
}

main() {
  weather
}

main
