#!/bin/bash

if wixd.arggt "1"; then
    dir="$1"
    if wixd.direxists "$dir"; then
        mydir="${mydirs[$dir]/\~/${HOME}}"
        sys.info "Opening $WIX_DIR..."
        sys.openfile "$WIX_DIR"
    else
        sys.error "Directory alias does not exist"
    fi
else
    sys.info "Opening current directory..."
    sys.openfile "$(pwd)"
fi