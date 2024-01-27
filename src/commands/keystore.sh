#!/bin/bash

if wixd.arggt "1"; then
    if wixd.arggt "2"; then
        wixd.check_keystore "$1" "$2"
    else
        wixd.check_keystore "$1"
    fi
else
    if sys.shell.zsh; then
        read "key?${GREEN}Enter the key you would like to add to your keystore:${RESET}"
    else
        read -rp "${GREEN}Enter the key you would like to add to your keystore:${RESET} " key
    fi
    wixd.check_keystore "$key"
fi
sys.info "You're done!"