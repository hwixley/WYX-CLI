#!/bin/bash

if mac; then
    info_text "Enter the SSID of the network you would like to get the password for:"
    read -r ssid
    info_text "Getting password for $ssid..."
    security find-generic-password -ga "$ssid" | grep "password:"
    echo ""
else
    info_text "Listing saved Wifi passwords:"
    sudo grep -r '^psk=' /etc/NetworkManager/system-connections/
fi