#!/bin/bash

if wyxd.arggt "1" ; then
    wgit.npush "$1"
else
    sys.log.info "Provide a branch name:"
    read -r name
    if [ "$name" != "" ]; then
        wgit.npush "$name"
    else
        sys.log.error "Invalid branch name"
    fi
fi