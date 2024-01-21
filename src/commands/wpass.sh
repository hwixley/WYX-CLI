#!/bin/bash

if sys.mac; then
    sys.info "Enter the SSID of the network you would like to get the password for:"
    read -r ssid
    sys.info "Getting password for $ssid..."
    security find-generic-password -ga "$ssid" | grep "password:"
    echo ""
else
    sys.info "Listing saved Wifi passwords:"
    sudo grep -r '^psk=' /etc/NetworkManager/system-connections/
fi