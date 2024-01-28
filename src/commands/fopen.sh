#!/bin/bash

if wyxd.arggt "1"; then
    dir="$1"
    if wyxd.direxists "$dir"; then
        mydir="${mydirs[$dir]/\~/${HOME}}"
        sys.info "Opening $WYX_DIR..."
        sys.util.openfile "$WYX_DIR"
    else
        sys.error "Directory alias does not exist"
    fi
else
    sys.info "Opening current directory..."
    sys.util.openfile "$(pwd)"
fi