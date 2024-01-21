#!/bin/bash

script_to_edit="$1"
if ! arggt "1"; then
    sys.info "What script would you like to edit?"
    read -r script_to_edit_prompt
    script_to_edit=$script_to_edit_prompt
fi
if scriptexists "$script_to_edit"; then
    sys.info "Editing $script_to_edit script..."
    editfile "$datadir/run-configs/$script_to_edit.sh"
else
    sys.error "This script does not exist... Please try again"
fi