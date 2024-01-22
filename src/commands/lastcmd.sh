#!/bin/bash

lastcmd=$(fc -ln -1)
trimmed=$(echo "$lastcmd" | xargs)
sys.util.clipboard "$trimmed"