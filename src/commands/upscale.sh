#!/bin/bash

fname="$1"
alpha="$2"
if ! arggt "1"; then
    sys.info "Enter the file you would like to upscale:"
    read -r url
    fname="$url"

    if ! arggt "2"; then
        sys.info "Enter the scale multiplier:"
        read -r mult
        alpha="$mult"
    fi
fi
sys.info "Upscaling $fname..."
python3 "$scriptdir/photo-upscale.py" "$fname" "$alpha" 