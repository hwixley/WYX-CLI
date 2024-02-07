#!/bin/bash

name="$1"
if ! wyxd.arggt "1"; then
    sys.log.info "What would you like to call your script? (no spaces)"
    read -r name_prompt
    name="$name_prompt"
fi
if [ -f "$WYX_DATA_DIR/$name.sh" ]; then
    sys.log.error "Error: this script name already exists"
else
    sys.log.info "Creating new script..."
    echo "$name=$name" >> "$WYX_DATA_DIR/run-configs.txt"
    touch "$WYX_DATA_DIR/run-configs/$name.sh"
    chmod u+x "$WYX_DATA_DIR/run-configs/$name.sh"
    sys.util.editfile "$WYX_DATA_DIR/run-configs/$name.sh"
fi