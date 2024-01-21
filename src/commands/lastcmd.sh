#!/bin/bash

lastcmd=$(fc -ln -1)
trimmed=$(echo "$lastcmd" | xargs)
sys.clipboard "$trimmed"