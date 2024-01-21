#!/bin/bash

if sys.mac; then
    /System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport scan
else
    python3 "${WIX_SCRIPT_DIR}/wifi_sniffer.py"
fi