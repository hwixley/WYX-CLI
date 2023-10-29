#!/bin/bash

# CLI CONSTS
mypath=$(readlink -f "${BASH_SOURCE:-$0}")
mydir=$(dirname "${mypath}")

# shellcheck source=src/functions.sh
source "${mydir}/src/functions.sh"

branch=""
if git rev-parse --git-dir > /dev/null 2>&1; then
	git_branch=$(git branch)
	branch=$(echo "${git_branch}" | sed -n -e 's/^\* \(.*\)/\1/p')
fi
git_remote=$(git config --get remote.origin.url)
remote=$(echo "${git_remote}" | sed 's/.*\/\([^ ]*\/[^.]*\).*/\1/')
repo_url=${remote#"git@github.com:"}
repo_url=${repo_url%".git"}


# AUTO UPDATE CLI

pull() {
	if [[ "$1" != "${branch}" ]]; then
		git checkout "$1"
	fi
	git pull origin "$1"
}

wix_update() {
	info_text "Checking for updates..."

	current_dir=$(pwd)
	cd "${mydir}" || return 1
	repo_branch=""
	if git rev-parse --git-dir > /dev/null 2>&1; then
		repo_branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
	fi
	if [[ "${repo_branch}" != "master" ]]; then
		warn_text "Not on master branch, skipping update"
		cd "${current_dir}" || return 1
		return 1
	fi 

	git fetch
	UPSTREAM=${1:-'@{u}'}
	LOCAL=$(git rev-parse @)
	REMOTE=$(git rev-parse "${UPSTREAM}")
	BASE=$(git merge-base @ "${UPSTREAM}")

	if [[ "${LOCAL}" = "${REMOTE}" ]]; then
		info_text "Up-to-date"
	elif [[ "${LOCAL}" = "${BASE}" ]]; then
		info_text "Updating..."
		pull "${branch}"
	elif [[ "${REMOTE}" = "${BASE}" ]]; then
		echo "Need to push"
	else
		echo "Diverged"
	fi
	echo ""
	# {
	cd "${current_dir}" || return 1
	# } &> /dev/null
}

wix_update ""

# ARGPARSE

# shellcheck source=src/completion.sh
source "${mydir}/src/completion.sh"
# shellcheck source=src/argparse.sh
source "${mydir}/src/argparse.sh" "${@:1}"