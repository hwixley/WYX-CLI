#!/bin/bash

if direxists "$1"; then
    wix_cd "$1"
    info_text "Opening up VSCode editor..."
    code .
else
    error_text "Error: this directory alias does not exist, please try again"
fi