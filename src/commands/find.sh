#!/bin/bash

if wyxd.arggt "1"; then
    # find . -type f -name "$1"
    find . -regextype posix-extended -regex ".*$1.*"
else
 sys.log.info "Enter the regex you would like to use:"
    read -r regex
    # find . -type f -name "$fname"
    find . -regextype posix-extended -regex "$regex"
fi
