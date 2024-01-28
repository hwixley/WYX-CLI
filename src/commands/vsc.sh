#!/bin/bash

if wyxd.direxists "$1"; then
    wyxd.cd "$1"
    sys.info "Opening up VSCode editor..."
    code .
else
    sys.error "Error: this directory alias does not exist, please try again"
fi