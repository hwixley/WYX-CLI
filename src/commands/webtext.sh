#!/bin/bash

if arggt "1"; then
    webtext "$1"
else
    sys.info "Enter the webpage you would like to parse:"
    read -r webpage
    webtext "$webpage"
fi
