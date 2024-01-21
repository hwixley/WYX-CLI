#!/bin/bash

hex_size=32
if arggt "1"; then
    if ! [[ "$1" =~ ^[0-9]+$ ]]; then
        error_text "Error: the base64-length argument must be an integer"
        return 1
    else
        hex_size=$2
    fi
fi
pass=$(openssl rand -base64 "$hex_size")
truncated_pass="${pass:0:$hex_size}"
info_text "Your random base64 string is: ${RESET}$truncated_pass"
clipboard "$truncated_pass"