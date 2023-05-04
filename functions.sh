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
	if [ "$1" = "" ]; then
		echo "$notsupported"
	else
		echo "${RED}$1${RESET}"
	fi
}

# VALIDATION
empty() {
	if [ "$1" = "" ]; then
		return 0
	else
		return 1
	fi
}

# MAC & LINUX FUNCTIONS
zsh() {
	if [[ "$SHELL" = *"zsh"* ]]; then
		return 0
	else
		return 1
	fi
}

openurl() {
	if zsh; then
		open "$1"
	else
		xdg-open "$1"
	fi
}

envfile() {
	if zsh; then
		echo "$HOME/.zshrc"
	else
		echo "$HOME/.bashrc"
	fi
	return 0
}

arm() {
	if zsh; then
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