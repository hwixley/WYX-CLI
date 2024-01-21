#!/bin/bash

if wixd.arggt "1"; then
    if wixd.arggt "2"; then
        check_keystore "$1" "$2"
    else
        check_keystore "$1"
    fi
else
    read -rp "${GREEN}Enter the key you would like to add to your keystore:${RESET} " key
    check_keystore "$key"
fi
sys.info "You're done!"