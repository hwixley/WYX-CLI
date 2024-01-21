#!/bin/bash

if arggt "1"; then
    # find . -type f -name "$2"
    find . -regextype posix-extended -regex ".*$2.*"
else
    info_text "Enter the regex you would like to use:"
    read -r regex
    # find . -type f -name "$fname"
    find . -regextype posix-extended -regex "$regex"
fi
