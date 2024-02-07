#!/bin/bash

if wyxd.direxists "$1"; then
    wyxd.cd "$1"
    sys.log.info "Opening up VSCode editor..."
    code .
else
    sys.log.error "Error: this directory alias does not exist, please try again"
fi