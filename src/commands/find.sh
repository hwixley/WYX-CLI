#!/bin/bash

if wyxd.arggt "1"; then
    sys.util.file_regex_search . ".*$1"
else
    sys.log.info "Enter the regex you would like to use:"
    read -r regex
    sys.util.file_regex_search . ".*$regex"
fi
