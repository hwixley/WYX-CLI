#!/bin/bash

git log --pretty=format:"${GREEN}%H${RESET} - ${BLUE}%an${RESET}, ${ORANGE}%cr [%cd]${RESET} : %s"