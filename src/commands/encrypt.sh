#!/bin/bash

sys.log.info "Encrypting $1..."
if wyxd.arggt "1"; then
    if [ -d "$1" ]; then
        tar -cvf "$1.tar" "$1"
        gpg -c "$1.tar"
        rm "$1.tar"
        sys.log.info "$1.tar.gpg file created successfully!"
    
    elif [ -f "$1" ]; then
        gpg -c "$1"
        sys.log.info "$1.gpg file created successfully!"
    
    else
        sys.log.error "File path provided does not exist. Please try again"
    fi
else
    sys.log.info "Enter the file/directory you would like to encrypt:"
    read -r filepath

    if [ -d "$filepath" ]; then
        tar -cvf "$filepath.tar" "$filepath"
        gpg -c "$filepath.tar"
        rm "$filepath.tar"
        sys.log.info "$filepath.tar.gpg file created successfully!"
    
    elif [ -f "$filepath" ]; then
        gpg -c "$filepath"
        sys.log.info "$filepath.gpg file created successfully!"

    else
        sys.log.error "File path provided does not exist. Please try again"
    fi
fi