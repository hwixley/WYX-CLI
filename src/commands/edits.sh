#!/bin/bash

script_to_edit="$1"
if ! wixd.arggt "1"; then
    sys.info "What script would you like to edit?"
    read -r script_to_edit_prompt
    script_to_edit=$script_to_edit_prompt
fi
if wixd.scriptexists "$script_to_edit"; then
    sys.info "Editing $script_to_edit script..."
    sys.util.editfile "$WIX_DATA_DIR/run-configs/$script_to_edit.sh"
else
    sys.error "This script does not exist... Please try again"
fi