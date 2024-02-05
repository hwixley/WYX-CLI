#!/bin/bash

fname="$1"
alpha="$2"
if ! wyxd.arggt "1"; then
 sys.log.info "Enter the file you would like to upscale:"
    read -r url
    fname="$url"

    if ! wyxd.arggt "2"; then
 sys.log.info "Enter the scale multiplier:"
        read -r mult
        alpha="$mult"
    fi
fi
sys.log.info "Upscaling $fname..."
python3 "$WYX_SCRIPT_DIR/photo_upscale.py" "$fname" "$alpha" 