#!/bin/bash

name="$1"
if ! arggt "1"; then
    info_text "What would you like to call your script? (no spaces)"
    read -r name_prompt
    name="$name_prompt"
fi
if [ -f "$datadir/$name.sh" ]; then
    error_text "Error: this script name already exists"
else
    info_text "Creating new script..."
    echo "$name=$name" >> "$datadir/run-configs.txt"
    touch "$datadir/run-configs/$name.sh"
    chmod u+x "$datadir/run-configs/$name.sh"
    editfile "$datadir/run-configs/$name.sh"
fi