#!/bin/bash

link="$1"
fname="$2"
if ! arggt "1"; then
    sys.info "Enter the URL you would like to link to:"
    read -r url
    link="$url"

    if ! arggt "2"; then
        sys.info "Enter the name for your QR code:"
        read -r qrname
        fname="$qrname"
    fi
fi
sys.info "Generating a QR code..."
qrencode -o "$fname.png" "$link"
display "$fname.png"