#!/bin/bash

name="$1"
if ! arggt "1"; then
    sys.info "What would you like to call your script? (no spaces)"
    read -r name_prompt
    name="$name_prompt"
fi
if [ -f "$datadir/$name.sh" ]; then
    sys.error "Error: this script name already exists"
else
    sys.info "Creating new script..."
    echo "$name=$name" >> "$datadir/run-configs.txt"
    touch "$datadir/run-configs/$name.sh"
    chmod u+x "$datadir/run-configs/$name.sh"
    editfile "$datadir/run-configs/$name.sh"
fi