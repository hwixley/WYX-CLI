#!/bin/bash

# CLI CONSTS
if [[ "$OSTYPE" == "darwin"* ]] || [[ "$(ps -o args= -p $$)" = *"zsh"* ]]; then
	mypath="${(%):-%N}"
else
	mypath="${BASH_SOURCE[0]}"
fi
WYX_DIR=$(dirname "$mypath")
WYX_DATA_DIR=$WYX_DIR/.wyx-cli-data
WYX_SCRIPT_DIR=$WYX_DIR/src/commands/scripts
export WYX_DIR WYX_DATA_DIR WYX_SCRIPT_DIR

source $WYX_DIR/src/classes/sys/sys.h
sys sys

branch=""
if git rev-parse --git-dir > /dev/null 2>&1; then
	branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
fi
remote=$(git config --get remote.origin.url | sed 's/.*\/\([^ ]*\/[^.]*\).*/\1/')
repo_url=${remote#"git@github.com:"}
repo_url=${repo_url%".git"}


# AUTO UPDATE CLI

pull() {
	if [ "$1" != "$branch" ]; then
		git checkout "$1"
	fi
	git pull origin "$1"
}

wyx_update() {
	sys.log.info "Checking for updates..."

	current_dir=$(pwd)
	cd "$WYX_DIR" || return 1
	repo_branch=""
	if git rev-parse --git-dir > /dev/null 2>&1; then
		repo_branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
	fi
	if [ "$repo_branch" != "master" ]; then
	sys.log.warn "Not on master branch, skipping update" && echo ""
		cd "$current_dir" || return 1
		return 1
	fi 

	git fetch
	UPSTREAM=${1:-'@{u}'}
	LOCAL=$(git rev-parse @)
	REMOTE=$(git rev-parse "$UPSTREAM")
	BASE=$(git merge-base @ "$UPSTREAM")

	if [ "$LOCAL" = "$REMOTE" ]; then
	sys.log.info "Up-to-date"
	elif [ "$LOCAL" = "$BASE" ]; then
	sys.log.info "Updating..."
		pull "$branch"
	elif [ "$REMOTE" = "$BASE" ]; then
		echo "Need to push"
	else
		echo "Diverged"
	fi
	echo ""
	# {
	cd "$current_dir" || return 1
	# } &> /dev/null
}

wyx_update ""

# ARGPARSE

source "$WYX_DIR/completion.sh"
source "$WYX_DIR/argparse.sh" "${@:1}"