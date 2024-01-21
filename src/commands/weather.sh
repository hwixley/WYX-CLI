#!/bin/bash

if arggt "1"; then
    city="$1"
    info_text "Getting weather for $city..."
    curl wttr.in/"$city"
else
    info_text "Getting weather for your current location..."
    curl wttr.in
fi