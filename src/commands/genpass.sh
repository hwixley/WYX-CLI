#!/bin/bash

pass_size=16
if wixd.arggt "1"; then
    if ! [[ "$1" =~ ^[0-9]+$ ]]; then
        sys.error "Error: the password-length argument must be an integer"
        return 1
    else
        pass_size=$1
    fi
fi
pass=$(python3 "${WIX_SCRIPT_DIR}/random_string_gen.py" "$pass_size")
sys.info "Your random password string is: ${RESET}$pass"
sys.util.clipboard "$pass"