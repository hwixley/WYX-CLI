#!/bin/bash

pass_size=16
if arggt "1"; then
    if ! [[ "$1" =~ ^[0-9]+$ ]]; then
        error_text "Error: the password-length argument must be an integer"
        return 1
    else
        pass_size=$2
    fi
fi
pass=$(python3 "${scriptdir}/random_string_gen.py" "$pass_size")
info_text "Your random password string is: ${RESET}$pass"
clipboard "$pass"