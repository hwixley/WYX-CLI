#!/bin/bash

if arggt "1"; then
    if arggt "2"; then
        check_keystore "$2" "$3"
    else
        check_keystore "$2"
    fi
else
    read -rp "${GREEN}Enter the key you would like to add to your keystore:${RESET} " key
    check_keystore "$key"
fi
info_text "You're done!"