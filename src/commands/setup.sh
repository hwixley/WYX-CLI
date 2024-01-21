#!/bin/bash

if [ "$1" = "openai_key" ]; then
    info_text "Setting up OpenAI key..."
    echo ""
    check_keystore "OPENAI_API_KEY"
    info_text "You're done!"

elif [ "$1" = "smart_commit" ]; then
    info_text "Setting up smart commit..."
    echo ""
    check_keystore "OPENAI_API_KEY"
    check_keystore "USE_SMART_COMMIT" "true"
    info_text "You're done!"
    
else
    error_text "Invalid setup command! Try again"
    echo "Type 'wix' to see the list of available commands (and their arguments), or 'wix help' to be redirected to more in-depth online documentation"
fi