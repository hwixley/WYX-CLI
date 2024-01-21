#!/bin/bash

if wixd.arggt "1"; then
    wgit.wix_ginit "$1"
else
    sys.info "Enter the webpage you would like to parse:"
    read -r webpage
    wgit.wix_ginit "$webpage"
fi
