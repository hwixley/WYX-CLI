#!/bin/bash

if [ "$1" = "openai_key" ]; then
 sys.log.info "Setting up OpenAI key..."
    echo ""
    wyxd.check_keystore "OPENAI_API_KEY"
 sys.log.info "You're done!"

elif [ "$1" = "smart_commit" ]; then
 sys.log.info "Setting up smart commit..."
    echo ""
    wyxd.check_keystore "OPENAI_API_KEY"
    wyxd.check_keystore "USE_SMART_COMMIT" "true"
 sys.log.info "You're done!"
    
else
 sys.log.error "Invalid setup command! Try again"
    echo "Type 'wyx' to see the list of available commands (and their arguments), or 'wyx help' to be redirected to more in-depth online documentation"
fi