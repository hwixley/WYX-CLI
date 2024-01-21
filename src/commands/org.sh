#!/bin/bash

if wixd.arggt "1"; then
    if orgexists "$1"; then
        wgit.giturl "https://github.com/${myorgs[$1]}"
    else
        sys.error "That organisation does not exist..."
        sys.info "Execute 'wix myorgs' to see your saved organisations"
    fi
else
    wgit.giturl "https://github.com/${myorgs[default]}"
fi