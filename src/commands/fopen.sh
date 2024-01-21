#!/bin/bash

if arggt "1"; then
    dir="$1"
    if direxists "$dir"; then
        mydir="${mydirs[$dir]/\~/${HOME}}"
        sys.info "Opening $mydir..."
        sys.openfile "$mydir"
    else
        sys.error "Directory alias does not exist"
    fi
else
    sys.info "Opening current directory..."
    sys.openfile "$(pwd)"
fi