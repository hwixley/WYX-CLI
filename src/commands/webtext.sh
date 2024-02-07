#!/bin/bash

if wyxd.arggt "1"; then
    sys.util.webtext "$1"
else
    sys.log.info "Enter the webpage you would like to parse:"
    read -r webpage
    sys.util.webtext "$webpage"
fi
