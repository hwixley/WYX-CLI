#!/bin/bash

quote_author=$(curl -s "https://quotesondesign.com/wp-json/wp/v2/posts/" | jq -r ".[0].title.rendered" | sed 's/<[^>]*>//g' | tr -d "\n")
quote_content=$(curl -s "https://quotesondesign.com/wp-json/wp/v2/posts/" | jq -r ".[0].content.rendered" | sed 's/<[^>]*>//g' | tr -d "\n")

echo ""
sys.log.info "\"${quote_content}\""
echo ""
sys.log.h2 "- ${quote_author}"
echo ""