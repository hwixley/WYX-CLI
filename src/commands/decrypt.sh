#!/bin/bash

info_text "Decrypting $2..."
if arggt "1"; then
    if [ -f "$2" ]; then
        gpg -d "$2"
        info_text "$2 file decrypted successfully!"
    else
        error_text "File path provided does not exist. Please try again"
    fi
else
    info_text "Enter the file you would like to decrypt: (must have a .gpg extension)"
    read -r filepath
    if [ -f "$filepath" ]; then
        gpg -d "$filepath"
        info_text "$filepath file decrypted successfully!"
    else
        error_text "File path provided does not exist. Please try again"
    fi
fi