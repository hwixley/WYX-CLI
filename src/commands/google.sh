#!/bin/bash

if arggt "1"; then
    sys.openurl "https://www.google.com/search?q=$1"
else
    prompt_text "\nEnter your Google search query:"
    read -r query
    sys.openurl "https://www.google.com/search?q=$query"
fi
echo ""