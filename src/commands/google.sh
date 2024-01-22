#!/bin/bash

if wixd.arggt "1"; then
    sys.util.openurl "https://www.google.com/search?q=$1"
else
    prompt_text "\nEnter your Google search query:"
    read -r query
    sys.util.openurl "https://www.google.com/search?q=$query"
fi
echo ""