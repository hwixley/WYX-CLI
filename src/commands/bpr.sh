#!/bin/bash

if git.is_git_repo ; then
    if wixd.arggt "1" ; then
        wgit.bpr "$@"
    else
        sys.info "Provide a branch name:"
        read -r name
        if [ "$name" != "" ]; then
            wgit.bpr "$name"
        fi
    fi
fi