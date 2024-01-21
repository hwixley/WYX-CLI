#!/bin/bash

# COMMAND INFO IMAGE OUTPUT - FOR GITHUB ACTIONS WORKFLOW

output=$(command_info | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2};?)?)?[mGK]//g")
output="\$ wix\n\n$output\n"

convert -background "#300A24" -fill white -font "DejaVu-Sans-Mono" -pointsize 18 -border 20x15 -bordercolor "#300A24" label:"$output" "${mydir}/.generated/wixcli-output-preview.png"