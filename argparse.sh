#!/bin/bash

# CLI CONSTS
version="2.1.0"
num_args=$#
date=$(date)
year="${date:24:29}"

# Load bash classes
source $WYX_DIR/src/classes/sys/sys.h
sys sys
source $WYX_DIR/src/classes/wgit/wgit.h
wgit wgit
source $WYX_DIR/src/classes/wyxd/wyxd.h
wyxd wyxd

# Load source git data
branch=""
if git rev-parse --git-dir > /dev/null 2>&1; then
	branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
fi
remote=$(git config --get remote.origin.url | sed 's/.*\/\([^ ]*\/[^.]*\).*/\1/')
repo_url=${remote#"git@github.com:"}
repo_url=${repo_url%".git"}


if [ $num_args -eq 0 ]; then
	# No input - show command info
	wyxd.command_info

else
	source $WYX_DIR/src/classes/cmd/cmd.h
	# Parse input into command object and run it (if valid)
	cmd inputCommand
	inputCommand.id '=' $1

	inputCommand_path="${WYX_DIR}/src/commands/$(inputCommand.path).sh"

	if [ -f "${inputCommand_path}" ]; then
		# Valid command found - run it
		source "${inputCommand_path}" "${@:2}"
		inputCommand.unset

	else
		# Invalid command - show error message
		sys.error "Invalid command! Try again"
		echo "Type 'wyx' to see the list of available commands (and their arguments), or 'wyx help' to be redirected to more in-depth online documentation"
	fi
fi

unset WYX_DIR WYX_DATA_DIR WYX_SCRIPT_DIR