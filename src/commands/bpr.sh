#!/bin/bash

if git.is_git_repo ; then
    if arggt "1" ; then
        wgit.bpr "$1"
    else
        sys.info "Provide a branch name:"
        read -r name
        if [ "$name" != "" ]; then
            wgit.bpr "$name"
        fi
    fi
fi