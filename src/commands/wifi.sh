#!/bin/bash

if sys.os.mac; then
    /System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport scan
else
    python3 "${WYX_SCRIPT_DIR}/wifi_sniffer.py"
fi