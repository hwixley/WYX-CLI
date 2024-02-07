#!/bin/bash

if sys.os.mac; then
    sys.log.info "Enter the SSID of the network you would like to get the password for:"
    read -r ssid
    sys.log.info "Getting password for $ssid..."
    security find-generic-password -ga "$ssid" | grep "password:"
    echo ""
else
    sys.log.info "Listing saved Wifi passwords:"
    sudo grep -r '^psk=' /etc/NetworkManager/system-connections/
fi