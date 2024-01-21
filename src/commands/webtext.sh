#!/bin/bash

if wixd.arggt "1"; then
    sys.webtext "$1"
else
    sys.info "Enter the webpage you would like to parse:"
    read -r webpage
    sys.webtext "$webpage"
fi
