#!/bin/bash

fname="$1"
alpha="$2"
if ! wixd.arggt "1"; then
    sys.info "Enter the file you would like to upscale:"
    read -r url
    fname="$url"

    if ! wixd.arggt "2"; then
        sys.info "Enter the scale multiplier:"
        read -r mult
        alpha="$mult"
    fi
fi
sys.info "Upscaling $fname..."
python3 "$WIX_SCRIPT_DIR/photo_upscale.py" "$fname" "$alpha" 