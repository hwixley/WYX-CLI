#!/bin/bash

if [ "$1" = "openai_key" ]; then
    sys.info "Setting up OpenAI key..."
    echo ""
    wyxd.check_keystore "OPENAI_API_KEY"
    sys.info "You're done!"

elif [ "$1" = "smart_commit" ]; then
    sys.info "Setting up smart commit..."
    echo ""
    wyxd.check_keystore "OPENAI_API_KEY"
    wyxd.check_keystore "USE_SMART_COMMIT" "true"
    sys.info "You're done!"
    
else
    sys.error "Invalid setup command! Try again"
    echo "Type 'wyx' to see the list of available commands (and their arguments), or 'wyx help' to be redirected to more in-depth online documentation"
fi