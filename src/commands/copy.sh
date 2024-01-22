#!/bin/bash

if wixd.arggt "1"; then
    if [[ "$1" =~ ^\$\(.*\)$ ]]; then
        DATA="$1"
        sys.util.clipboard "$DATA"
    else
        sys.util.clipboard "$1"
    fi
else
    sys.info "Enter the text you would like to copy to your sys.util.clipboard:"
    read -r text
    sys.util.clipboard "$text"
fi