#!/bin/bash

if mac; then
    networksetup -listallhardwareports
else
    echo "Not supported on this OS"
fi
