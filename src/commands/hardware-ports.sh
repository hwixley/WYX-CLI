#!/bin/bash

if sys.os.mac; then
    networksetup -listallhardwareports
else
    echo "Not supported on this OS"
fi
