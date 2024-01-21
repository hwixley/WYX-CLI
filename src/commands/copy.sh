#!/bin/bash

if arggt "1"; then
    if [[ "$1" =~ ^\$\(.*\)$ ]]; then
        DATA="$1"
        clipboard "$DATA"
    else
        clipboard "$1"
    fi
else
    info_text "Enter the text you would like to copy to your clipboard:"
    read -r text
    clipboard "$text"
fi