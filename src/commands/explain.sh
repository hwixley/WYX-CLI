#!/bin/bash

if arggt "1"; then
    cmd="$1"
    info_text "Finding explanation for $cmd..."
    cmd="${cmd// /+}"
    openurl "https://explainshell.com/explain?cmd=$cmd"
else
    info_text "Enter the command you would like to explain:"
    read -r cmd
    info_text "Finding explanation for $cmd..."
    cmd="${cmd// /+}"
    openurl "https://explainshell.com/explain?cmd=$cmd"
fi