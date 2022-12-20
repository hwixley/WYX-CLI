#!/bin/bash

# COLORS
GREEN=$(tput setaf 2)
ORANGE=$(tput setaf 3)
RED=$(tput setaf 1)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
BLACK=$(tput setaf 0)
RESET=$(tput setaf 7)

# FILE EXTs
exts=("sh" "txt" "py")

# FILES
function readfile() {
	declare -n ary="$1"
	readarray -t lines < "$2"

	for line in "${lines[@]}"; do
	   key=${line%%=*}
	   value=${line#*=}
	   ary[$key]=$value
	done
}

# PROMPTS
function info_text() {
	echo "${GREEN}$1${RESET}"
}

function h1_text() {
	echo "${BLUE}$1${RESET}"
}

function h2_text() {
	echo "${CYAN}$1${RESET}"
}

function warn_text() {
	echo "${ORANGE}$1${RESET}"
}

function error_text() {
	if [ "$1" = "" ]; then
		echo $notsupported
	else
		echo "${RED}$1${RESET}"
	fi
}

# VALIDATION
function empty() {
	if [ "$1" = "" ]; then
		return 0
	else
		return 1
	fi
}

# MAC & LINUX FUNCTIONS
function mac() {
	if [ "$(uname)" == "Darwin" ]; then
		return 0
	else
		return 1
	fi
}

function openurl() {
	if mac; then
		open $1
	else
		xdg-open $1
	fi
}

function arraykeys() {
	arg=$1
	if mac; then
		return "${(@k)arg}"
	else
		return "${!arg[@]}"
	fi
}

function envfile() {
	if mac; then
		return ~/.zshrc
	else
		return ~/.bashrc
	fi
}