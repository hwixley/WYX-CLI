#!/bin/bash

# CLI CONSTS
version="3.1.2"
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
source $WYX_DIR/src/classes/lib/lib.h
lib lib

# Load source git data
branch=""
if git rev-parse --git-dir > /dev/null 2>&1; then
	branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
fi
remote=$(git config --get remote.origin.url)
repo_url=$(echo "$remote" | sed 's/[^ \/]*\/\([^ ]*\/[^.]*\).*/\1/')
repo_url=${repo_url%".git"}
git_host=""
if [[ $remote == *"github.com"* ]]; then
	git_host="github"
	repo_url=${repo_url#"git@github.com:"}
elif [[ $remote == *"gitlab.com"* ]]; then
	git_host="gitlab"
	repo_url=${repo_url#"git@gitlab.com:"}
elif [[ $remote == *"bitbucket.org"* ]]; then
	git_host="bitbucket"
	repo_url=$(echo "$repo_url" | sed 's/\/[^ \/]*\/\([^ \/]*\/[^ \/]*\)/\1/')
elif [[ $remote == *"azure.com"* ]]; then
	git_host="azure"
	org=$(echo "$repo_url" | sed 's/\([^ \/]*\).*/\1/')
	project=$(echo "$repo_url" | sed 's/[^ \/]*\/\([^ \/]*\).*/\1/')
	repo=$(echo "$repo_url" | sed 's/.*\/\([^ \/]*\)/\1/')
	repo_url="${org}/${project}/_git/${repo}"
fi



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
		sys.log.error "Invalid command! Try again"
		echo "Type 'wyx' to see the list of available commands (and their arguments), or 'wyx help' to be redirected to more in-depth online documentation"
	fi
fi

unset WYX_DIR WYX_DATA_DIR WYX_SCRIPT_DIR