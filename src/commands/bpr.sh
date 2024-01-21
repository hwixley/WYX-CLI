#!/bin/bash

if is_git_repo ; then
    if arggt "1" ; then
        bpr "$1"
    else
        info_text "Provide a branch name:"
        read -r name
        if [ "$name" != "" ]; then
            bpr "$name"
        fi
    fi
fi