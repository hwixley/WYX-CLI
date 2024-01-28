#!/bin/bash

if wyxd.arggt "1"; then
    if wyxd.orgexists "$1"; then
        wgit.giturl "https://github.com/$(wyxd.org $1)"
    else
        sys.error "That organisation does not exist..."
        sys.info "Execute 'wyx myorgs' to see your saved organisations"
    fi
else
    wgit.giturl "https://github.com/$(wyxd.org default)"
fi