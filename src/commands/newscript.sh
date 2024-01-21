#!/bin/bash

name="$1"
if ! wixd.arggt "1"; then
    sys.info "What would you like to call your script? (no spaces)"
    read -r name_prompt
    name="$name_prompt"
fi
if [ -f "$WIX_DATA_DIR/$name.sh" ]; then
    sys.error "Error: this script name already exists"
else
    sys.info "Creating new script..."
    echo "$name=$name" >> "$WIX_DATA_DIR/run-configs.txt"
    touch "$WIX_DATA_DIR/run-configs/$name.sh"
    chmod u+x "$WIX_DATA_DIR/run-configs/$name.sh"
    sys.editfile "$WIX_DATA_DIR/run-configs/$name.sh"
fi