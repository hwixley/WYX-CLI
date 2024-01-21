#!/bin/bash

if wixd.arggt "1"; then
    if [[ "$1" =~ ^\$\(.*\)$ ]]; then
        DATA="$1"
        sys.clipboard "$DATA"
    else
        sys.clipboard "$1"
    fi
else
    sys.info "Enter the text you would like to copy to your sys.clipboard:"
    read -r text
    sys.clipboard "$text"
fi