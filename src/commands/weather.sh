#!/bin/bash

if wyxd.arggt "1"; then
    city="$1"
    sys.log.info "Getting weather for $city..."
    curl wttr.in/"$city"
else
    sys.log.info "Getting weather for your current location..."
    curl wttr.in
fi