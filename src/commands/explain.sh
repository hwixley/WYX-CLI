#!/bin/bash

if wyxd.arggt "1"; then
    cmd="$1"
    sys.log.info "Finding explanation for $cmd..."
    cmd="${cmd// /+}"
    sys.util.openurl "https://explainshell.com/explain?cmd=$cmd"
else
    sys.log.info "Enter the command you would like to explain:"
    read -r cmd
    sys.log.info "Finding explanation for $cmd..."
    cmd="${cmd// /+}"
    sys.util.openurl "https://explainshell.com/explain?cmd=$cmd"
fi