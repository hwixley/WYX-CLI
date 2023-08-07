#!/bin/bash

# CLI CONSTS
mypath=$(readlink -f "${BASH_SOURCE:-$0}")
mydir=$(dirname "$mypath")

source $mydir/functions.sh

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
	info_text "Checking for updates..."

	cd "$mydir" || return 1
	repo_branch=""
	if git rev-parse --git-dir > /dev/null 2>&1; then
		repo_branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
	fi
	if [ "$repo_branch" != "master" ]; then
		warn_text "Not on master branch, skipping update"
		return 1
	fi 

	git fetch
	UPSTREAM=${1:-'@{u}'}
	LOCAL=$(git rev-parse @)
	REMOTE=$(git rev-parse "$UPSTREAM")
	BASE=$(git merge-base @ "$UPSTREAM")

	if [ "$LOCAL" = "$REMOTE" ]; then
		info_text "Up-to-date"
	elif [ "$LOCAL" = "$BASE" ]; then
		info_text "Updating..."
		pull "$branch"
	elif [ "$REMOTE" = "$BASE" ]; then
		echo "Need to push"
	else
		echo "Diverged"
	fi
	echo ""
	{
		cd - || return 1
	} &> /dev/null
}

wix_update ""

# ARGPARSE

source "$mydir/argparse.sh" "${@:1}"