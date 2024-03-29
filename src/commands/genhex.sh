#!/bin/bash

hex_size=32
if wyxd.arggt "1"; then
    if ! [[ "$1" =~ ^[0-9]+$ ]]; then
        sys.log.error "Error: the hex-length argument must be an integer"
        return 1
    else
        hex_size=$1
    fi
fi
pass=$(openssl rand -hex "$hex_size")
truncated_pass="${pass:0:$hex_size}"
sys.log.info "Your random hex string is: ${RESET}$truncated_pass"
sys.util.clipboard "$truncated_pass"