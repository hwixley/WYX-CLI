#!/bin/bash

if arggt "1"; then
    dir="$1"
    if direxists "$dir"; then
        mydir="${mydirs[$dir]/\~/${HOME}}"
        info_text "Opening $mydir..."
        openfile "$mydir"
    else
        error_text "Directory alias does not exist"
    fi
else
    info_text "Opening current directory..."
    openfile "$(pwd)"
fi