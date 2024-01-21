#!/bin/bash

fname="$1"
alpha="$2"
if ! arggt "1"; then
    info_text "Enter the file you would like to upscale:"
    read -r url
    fname="$url"

    if ! arggt "2"; then
        info_text "Enter the scale multiplier:"
        read -r mult
        alpha="$mult"
    fi
fi
info_text "Upscaling $fname..."
python3 "$scriptdir/photo-upscale.py" "$fname" "$alpha" 