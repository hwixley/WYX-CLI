#!/bin/bash

# CLI CONSTS
if [[ "$OSTYPE" == "darwin"* ]] || [[ "$(ps -o args= -p $$)" = *"zsh"* ]]; then
	mypath="${(%):-%N}"
else
	mypath="${BASH_SOURCE[0]}"
fi
WIX_DIR=$(dirname "$mypath")
WIX_DATA_DIR=$WIX_DIR/.wix-cli-data
WIX_SCRIPT_DIR=$WIX_DIR/src/commands/scripts
export WIX_DIR WIX_DATA_DIR WIX_SCRIPT_DIR

source $WIX_DIR/src/classes/sys/sys.h
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

wix_update() {
	sys.info "Checking for updates..."

	current_dir=$(pwd)
	cd "$WIX_DIR" || return 1
	repo_branch=""
	if git rev-parse --git-dir > /dev/null 2>&1; then
		repo_branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
	fi
	if [ "$repo_branch" != "master" ]; then
		sys.warn "Not on master branch, skipping update" && echo ""
		cd "$current_dir" || return 1
		return 1
	fi 

	git fetch
	UPSTREAM=${1:-'@{u}'}
	LOCAL=$(git rev-parse @)
	REMOTE=$(git rev-parse "$UPSTREAM")
	BASE=$(git merge-base @ "$UPSTREAM")

	if [ "$LOCAL" = "$REMOTE" ]; then
		sys.info "Up-to-date"
	elif [ "$LOCAL" = "$BASE" ]; then
		sys.info "Updating..."
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

wix_update ""

# ARGPARSE

source "$WIX_DIR/completion.sh"
source "$WIX_DIR/argparse.sh" "${@:1}"