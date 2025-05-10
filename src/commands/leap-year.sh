#!/bin/bash

year=$(date +%Y)
if [[ "$year" =~ ^[0-9]*00$ ]]; then
    if [ "$((year % 400))" -eq 0 ]; then
        sys.log.info "$year is a leap year"
    else
        sys.log.info "$year is not a leap year"
    fi
elif [ "$((year % 4))" -eq 0 ]; then
    sys.log.info "$year is a leap year"
else
    sys.log.info "$year is not a leap year"
fi
next_one=$((year + 4 - (year % 4)))
sys.log.info "The next leap year is $next_one"