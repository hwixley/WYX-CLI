#!/bin/bash

if direxists "$1"; then
    wixd.cd "$1"
    sys.info "Opening up VSCode editor..."
    code .
else
    sys.error "Error: this directory alias does not exist, please try again"
fi