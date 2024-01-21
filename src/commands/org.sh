#!/bin/bash

if arggt "1"; then
    if orgexists "$1"; then
        giturl "https://github.com/${myorgs[$1]}"
    else
        sys.error "That organisation does not exist..."
        sys.info "Execute 'wix myorgs' to see your saved organisations"
    fi
else
    giturl "https://github.com/${myorgs[default]}"
fi