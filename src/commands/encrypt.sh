#!/bin/bash

info_text "Encrypting $1..."
if arggt "1"; then
    if [ -d "$1" ]; then
        tar -cvf "$1.tar" "$1"
        gpg -c "$1.tar"
        rm "$1.tar"
        info_text "$1.tar.gpg file created successfully!"
    
    elif [ -f "$1" ]; then
        gpg -c "$1"
        info_text "$1.gpg file created successfully!"
    
    else
        error_text "File path provided does not exist. Please try again"
    fi
else
    info_text "Enter the file/directory you would like to encrypt:"
    read -r filepath

    if [ -d "$filepath" ]; then
        tar -cvf "$filepath.tar" "$filepath"
        gpg -c "$filepath.tar"
        rm "$filepath.tar"
        info_text "$filepath.tar.gpg file created successfully!"
    
    elif [ -f "$filepath" ]; then
        gpg -c "$filepath"
        info_text "$filepath.gpg file created successfully!"

    else
        error_text "File path provided does not exist. Please try again"
    fi
fi