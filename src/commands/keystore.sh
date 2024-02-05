#!/bin/bash

if wyxd.arggt "1"; then
    if wyxd.arggt "2"; then
        wyxd.check_keystore "$1" "$2"
    else
        wyxd.check_keystore "$1"
    fi
else
    if sys.shell.zsh; then
        read "key?${GREEN}Enter the key you would like to add to your keystore:${RESET}"
    else
        read -rp "${GREEN}Enter the key you would like to add to your keystore:${RESET} " key
    fi
    wyxd.check_keystore "$key"
fi
sys.log.info "You're done!"