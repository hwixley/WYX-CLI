#!/bin/bash

if wyxd.arggt "1"; then
    cmd="$1"
    sys.info "Finding explanation for $cmd..."
    cmd="${cmd// /+}"
    sys.util.openurl "https://explainshell.com/explain?cmd=$cmd"
else
    sys.info "Enter the command you would like to explain:"
    read -r cmd
    sys.info "Finding explanation for $cmd..."
    cmd="${cmd// /+}"
    sys.util.openurl "https://explainshell.com/explain?cmd=$cmd"
fi