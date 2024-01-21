#!/bin/bash

if arggt "1" ; then
    npush "$1"
else
    sys.info "Provide a branch name:"
    read -r name
    if [ "$name" != "" ]; then
        npush "$name"
    else
        sys.error "Invalid branch name"
    fi
fi