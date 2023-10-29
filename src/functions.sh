#!/bin/bash

# COLORS
GREEN=$(tput setaf 2)
ORANGE=$(tput setaf 3)
RED=$(tput setaf 1)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
# BLACK=$(tput setaf 0)
RESET=$(tput setaf 7)
export GREEN
export ORANGE
export RED
export BLUE
export CYAN
export RESET

# FILE EXTs
export exts=("sh" "txt" "py")

# CONST STRING PROMPTS
export notsupported="${RED}This path is not supported${RESET}"

# PROMPTS
info_text() {
	echo "${GREEN}$1${RESET}"
}

h1_text() {
	echo "${BLUE}$1${RESET}"
}

h2_text() {
	echo "${CYAN}$1${RESET}"
}

warn_text() {
	echo "${ORANGE}$1${RESET}"
}

error_text() {
	if [[ "$1" = "" ]]; then
		echo "${notsupported}"
	else
		echo "${RED}$1${RESET}"
	fi
}

# VALIDATION
empty() {
	if [[ "$1" = "" ]]; then
		return 0
	else
		return 1
	fi
}

# MAC & LINUX FUNCTIONS
using_zsh() {
	if [[ "$(ps -o args= -p $$)" = *"zsh"* ]]; then
		return 0
	else
		return 1
	fi
}

openurl() {
	if using_zsh; then
		open "$1"
	else
		{
			xdg-open "$1"
		} &> /dev/null
	fi
}

envfile() {
	if using_zsh; then
		echo "${HOME}/.zshrc"
	else
		echo "${HOME}/.bashrc"
	fi
	return 0
}

arm() {
	if using_zsh; then
		if [[ "$(sysctl -n sysctl.proc_translated)" == "1" ]] || [[ "$(uname -m)" == "arm64" ]]; then
			return 0;
		else
			return 1;
		fi
	else
		return 1;
	fi
}

openfile() {
	xdg-open "file:///$1"
}

mac() {
	if [[ "${OSTYPE}" == "darwin"* ]]; then
		return 0
	else
		return 1
	fi
}

clipboard() {
	if command -v pbcopy >/dev/null 2>&1; then
		info_text "This has been saved to your clipboard!"
		echo "$1" | pbcopy
	elif command -v xclip >/dev/null 2>&1; then
		info_text "This has been saved to your clipboard!"
		echo "$1" | xclip -selection c
	else
		warn_text "Clipboard not supported on this system, please install xclip or pbcopy."
	fi
}

editfile() {
    if using_zsh; then
        vi "$1"
    else
        gedit "$1"
    fi
}