#!/bin/bash

if arggt "1"; then
    webtext "$1"
else
    info_text "Enter the webpage you would like to parse:"
    read -r webpage
    webtext "$webpage"
fi
