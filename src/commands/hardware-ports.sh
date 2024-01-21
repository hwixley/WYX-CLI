#!/bin/bash

if sys.mac; then
    networksetup -listallhardwareports
else
    echo "Not supported on this OS"
fi
