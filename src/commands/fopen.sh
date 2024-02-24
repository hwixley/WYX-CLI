#!/bin/bash

if wyxd.arggt "1"; then
    dir="$1"
    if wyxd.direxists "$dir"; then
        mydir="${mydirs[$dir]/\~/${HOME}}"
        sys.log.info "Opening $WYX_DIR..."
        sys.util.openfile "$WYX_DIR"
    elif [ -f "$dir" ]; then
        sys.log.info "Opening file..."
        sys.util.openfile "$dir"
    else
        sys.log.error "Invalid directory or file"
    fi
else
    sys.log.info "Opening current directory..."
    sys.util.openfile "$(pwd)"
fi