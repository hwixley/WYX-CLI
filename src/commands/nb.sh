#!/bin/bash

if arggt "1" ; then
    npush "$1"
else
    info_text "Provide a branch name:"
    read -r name
    if [ "$name" != "" ]; then
        npush "$name"
    else
        error_text "Invalid branch name"
    fi
fi