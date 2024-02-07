#!/bin/bash

sys.log.info "Decrypting $1..."
if wyxd.arggt "1"; then
    if [ -f "$1" ]; then
        gpg -d "$1"
        sys.log.info "$1 file decrypted successfully!"
    else
        sys.log.error "File path provided does not exist. Please try again"
    fi
else
    sys.log.info "Enter the file you would like to decrypt: (must have a .gpg extension)"
    read -r filepath
    if [ -f "$filepath" ]; then
        gpg -d "$filepath"
        sys.log.info "$filepath file decrypted successfully!"
    else
        sys.log.error "File path provided does not exist. Please try again"
    fi
fi