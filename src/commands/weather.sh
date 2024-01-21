#!/bin/bash

if arggt "1"; then
    city="$1"
    sys.info "Getting weather for $city..."
    curl wttr.in/"$city"
else
    sys.info "Getting weather for your current location..."
    curl wttr.in
fi