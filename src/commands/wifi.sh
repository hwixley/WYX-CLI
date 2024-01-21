#!/bin/bash

if mac; then
    /System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport scan
else
    python3 "${scriptdir}/wifi_sniffer.py"
fi