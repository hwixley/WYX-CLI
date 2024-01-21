#!/bin/bash

sys.info "Decrypting $1..."
if wixd.arggt "1"; then
    if [ -f "$1" ]; then
        gpg -d "$1"
        sys.info "$1 file decrypted successfully!"
    else
        sys.error "File path provided does not exist. Please try again"
    fi
else
    sys.info "Enter the file you would like to decrypt: (must have a .gpg extension)"
    read -r filepath
    if [ -f "$filepath" ]; then
        gpg -d "$filepath"
        sys.info "$filepath file decrypted successfully!"
    else
        sys.error "File path provided does not exist. Please try again"
    fi
fi