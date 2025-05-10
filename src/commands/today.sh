#!/bin/bash

today_date=$(date)
my_city=$(curl -s https://ipinfo.io/city)
today_weather=$(curl -s "wttr.in/${my_city}")
today_moon=$(curl -s wttr.in/moon)
quote_author=$(curl -s "https://quotesondesign.com/wp-json/wp/v2/posts/" | jq -r ".[0].title.rendered" | sed 's/<[^>]*>//g' | tr -d "\n")
quote_content=$(curl -s "https://quotesondesign.com/wp-json/wp/v2/posts/" | jq -r ".[0].content.rendered" | sed 's/<[^>]*>//g' | tr -d "\n")

sys.log.hR
sys.log.h2 "TODAY'S STATS:"
sys.log.hR
sys.log.info "DATE: ${RESET}${today_date}"
sys.log.hR
sys.log.info "WEATHER:"
sys.log.hr
echo "${today_weather}"
sys.log.hR
sys.log.info "MOON PHASE:"
sys.log.hr
echo "${today_moon}"
sys.log.hR
sys.log.info "QUOTE:"
sys.log.hr
echo ""
sys.log.info "\"${quote_content}\""
echo ""
sys.log.h2 "- ${quote_author}"
echo ""
sys.log.hR