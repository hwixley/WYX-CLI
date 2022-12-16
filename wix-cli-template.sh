#!/bin/bash

envfile=~/.bashrc

if [ "$(uname)" = "Darwin" ]; then
    envfile=~/.zshrc
fi

# COLORS
GREEN=$(tput setaf 2)
ORANGE=$(tput setaf 3)
RED=$(tput setaf 1)
RESET=$(tput setaf 7)

# CLI CONSTS
num_args=$#
mypath=~/Documents/personal/wix-cli/wix-cli-template.sh

# GIT CONSTS
user=hwixley
branch=""
if git rev-parse --git-dir > /dev/null 2>&1; then
	branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
fi
remote=$(git config --get remote.origin.url | sed 's/.*\/\([^ ]*\/[^.]*\).*/\1/')
repo_url=${remote#"git@github.com:"}
repo_url=${repo_url%".git"}

declare -A myorgs
myorgs[va]="venn-apps"

# DIR CONSTS
insertline=38

declare -A mydirs
mydirs[docs]=~/Documents
mydirs[self]=~/Documents/personal/wix-cli
mydirs[down]=~/Downloads
mydirs[pix]=~/Pictures
mydirs[va]=~/Documents/venn-apps
mydirs[api]=~/Documents/venn-apps/VennAPI
mydirs[ios]=~/Documents/venn-apps/VennWL-iOS

diraliases=""
diraliasKeys=""
if [ "$(uname)" != "Darwin" ]; then
    diraliases=$(echo "${!mydirs[@]}" | sed 's/ / - /g' )
    diraliasKeys=$(echo ${!mydirs[@]} | sed 's/ / /g' )
else
    diraliases=$(echo "${(@k)mydirs}" | sed 's/ / - /g' )
    diraliasKeys=$(echo ${(@k)mydirs} | sed 's/ / /g' )
fi

# FILE EXTs
exts=("sh" "txt" "py")

# PROMPTS
notsupported="${RED}That path is not supported try: $diraliases"

# MODULAR FUNCTIONS
function info_text() {
	echo "${GREEN}$1${RESET}"
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

function empty() {
	if [ "$1" = "" ]; then
		return 0
	else
		return 1
	fi
}

function mac() {
    if [ "$(uname)" = "Darwin" ]; then
        return 0
    else
        return 1
    fi
}

function arggt() {
	if [ "$num_args" -gt "$1" ]; then
		return 0
	else
		return 1
	fi	
}

function direxists() {
	if [[ -v mydirs[$1] ]]; then
		return 0
	else
		return 1
	fi
}

function orgexists() {
	if [[ -v myorgs[$1] ]]; then
		return 0
	else
		return 1
	fi
}

function is_git_repo() {
	if git rev-parse --git-dir > /dev/null 2>&1; then
		branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
	fi
	if ! empty $branch ; then
		return 0
	else
		error_text "This is not a git repository..."
		return 1
	fi
}

function commit() {
	git add .
	if empty $1 ; then
		info_text "Provide a commit description:"
		read description
		git commit -m "${description:-wix-cli quick commit}"
	else
		git commit -m "${1:-wix-cli quick commit}"
	fi
}

function push() {
	if [ "$1" != "$branch" ]; then
		git checkout $1
	fi
	commit $2
	git push origin $1
}

function npush() {
	git checkout -b $1
	commit $2
	git push origin $1
}

function bpr() {
	npush $1
	info_text "Creating PR for $branch in $repo_url..."
	openurl "https://github.com/$repo_url/pull/new/$branch"
}

function openurl() {
	info_text "$1..."
    if mac; then
        open "$1"
    else
        xdg-open "$1"
    fi
}

function ginit() {
	git init
	if empty $2 ; then
		info_text "Provide a name for this repository:"
		read rname
		echo "# $rname" >> README.md
		commit "wix-cli: first commit"
		git remote add origin "git@github.com:$1/$rname.git"
		openurl "https://github.com/$3"
	else
		echo "# $2" >> README.md
		commit "wix-cli: first commit"
		git remote add origin "git@github.com:$1/$2.git"
		openurl "https://github.com/$3"
	fi
}

# COMMAND FUNCTIONS
function wix_cd() {
	if arggt "1" ; then
		if direxists $1 ; then
			destination=$mydirs[$1]
			if ! empty $2 ; then
				destination=$mydirs[$1]/$2
			fi
			if [ -d "$destination" ]; then
				info_text "Travelling to -> $destination"
				cd $destination
				return 0
			else
				error_text "The path $destination does not exist"
				return 1
			fi
		else
			error_text
			return 1
		fi
	else
		info_text "Where do you want to go?"
		read dir
		if direxists $dir ; then
			info_text "Travelling to -> ${mydirs[$dir]}"
			cd ${mydirs[$dir]}
			return 0
		else
			error_text
			return 1
		fi
	fi
}

function wix_new() {
	if direxists $1 ; then
		if empty $2 ; then
			info_text "Provide a name for this directory:"
			read dname
			info_text "Generating new dir (${mydirs[$1]}/$dname)..."
			mkdir ${mydirs[$1]}/$dname
			cd ${mydirs[$1]}/$dname
		else
			info_text "Generating new dir (${mydirs[$1]}/$2)..."
			mkdir ${mydirs[$1]}/$2
			cd ${mydirs[$1]}/$2
		fi
		return 0
	else
		error_text
		return 1
	fi
}

function wix_run() {
    if [ "$1" = "api" ]; then
        vennapi
    elif [ "$1" = "ios" ]; then
        vennios
    else
        error_text "$1 is not supported..."
        warn_text "Add your own environment setups on the sh file in the 'wix_run' function"
    fi
}

function wix_delete() {
	if direxists $1 ; then
		if empty "$2" ; then
			error_text "You did not provide a path in this directory to delete, try again..."
		else
			error_text "Are you sure you want to delete ${mydirs[$1]}/$2? [ Yy / Nn]"
			read response
			if [ $response = "y" ] || [ $response = "Y" ]
			then
				error_text "Are you really sure you want to delete ${mydirs[$1]}/$2? [ Yy / Nn]"
				read response
				if [ $response = "y" ] || [ $response = "Y" ]
				then
					error_text "Deleting ${mydirs[$1]}/$2"
					rm -rf ${mydirs[$1]}/$2
				fi
			fi
		fi
	else
		error_text
	fi
}

# GITHUB AUTOMATION COMMAND FUNCTIONS
function wix_ginit() {
	if wix_cd $1 $2 ; then
		if empty $branch ; then
			if orgexists $1 ; then
				ginit ${myorgs[$1]} $2 "organizations/${myorgs[$1]}/repositories/new"
			else
				ginit $user $2 "new"
			fi
		else
			error_text "This is already a git repository..."
		fi
	fi
}

function wix_gnew() {	
	if wix_new $1 $2 ; then
		wix_ginit $1 $2
	fi
}

function giturl() {
	if is_git_repo ; then
		openurl $1
	fi
}

# DEFAULT

if [ $num_args -eq 0 ]; then
	echo "Welcome to the..."
	echo ""
	info_text " ██╗    ██╗██╗██╗  ██╗     ██████╗██╗     ██╗ "
	info_text " ██║    ██║██║╚██╗██╔╝    ██╔════╝██║     ██║ "
	info_text " ██║ █╗ ██║██║ ╚███╔╝     ██║     ██║     ██║ "
	info_text " ██║███╗██║██║ ██╔██╗     ██║     ██║     ██║ "
	info_text " ╚███╔███╔╝██║██╔╝ ██╗    ╚██████╗███████╗██║ "
	info_text "  ╚══╝╚══╝ ╚═╝╚═╝  ╚═╝     ╚═════╝╚══════╝╚═╝ "
	echo ""
	echo "v0.0.0.0"
	echo ""
	info_text "COMMANDS:"
	echo "- cd <cdir> 			: navigation"
	echo "- back 				: return to last dir"
	echo "- new <cdir> <subdir>		: new directory"
	echo "- run <cdir> 			: setup and run environment"
	echo "- delete <cdir> <subdir> 	: delete dir"
	echo ""
	info_text "GITHUB AUTOMATION:"
	echo "- push <branch?>		: push changes"
	echo "- ginit <org?> <repo>		: init git repo"
	echo "- gnew <cdir/org> <repo> 	: create and init git repo"
	echo "- repo 				: go to repo url"
	echo "- branch 			: go to branch url"
	echo "- nbranch <name?>		: create new branch"
	echo "- pr 				: create PR for branch"
	echo "- bpr 				: checkout changes and create PR for branch"
	echo ""
	info_text "CLI management:"
	echo "- edit"
	echo "- save"
	echo "- cat"
	echo "- cdir"
	echo "- mydirs"


# GENERAL

elif [ "$1" = "cd" ]; then
	wix_cd $2
	
elif [ "$1" = "new" ]; then
	wix_new $2 $3
	
elif [ "$1" = "run" ]; then
	wix_run $2
	
elif [ "$1" = "delete" ]; then
	wix_delete $2 $3

# CLI MANAGEMENT

elif [ "$1" = "edit" ]; then
    fpath=$mypath
    warn_text "Edit $fpath file..."
    if ! empty "$2"; then
        fpath="$2"
    fi
    if mac; then
        open -a Xcode $fpath
    else
        gedit $fpath
    fi
	info_text "Saving changes to $mypath..."
	source "$envfile"
	
elif [ "$1" = "save" ]; then
	info_text "Sourcing bash :)"
	source "$envfile"
	
elif [ "$1" = "cat" ]; then
	cat $my_path

elif [ "$1" = "cdir" ]; then
	info_text "Enter an alias for your new directory:"
	read alias
	info_text "Enter the directory:"
	read i_dir
	info_text "Adding $alias=$i_dir to custom dirs"
	sed -i "${insertline}imydirs[$alias]=$i_dir" $mypath
	wix save
	
elif [ "$1" = "mydirs" ]; then
    echo $diraliasKeys
	for x in $diraliasKeys; do
        echo $x
        printf "[%s]=%s\n" "$x" "$(mydirs[$x])"
    done
	

# GITHUB AUTOMATION

elif [ "$1" = "gnew" ]; then
	wix_gnew $2 $3
	
elif [ "$1" = "ginit" ]; then
	wix_ginit $2 $3
	
elif [ "$1" = "push" ]; then
	if arggt "1" ; then
		push $2
	else
		push $branch
	fi
elif [ "$1" = "repo" ]; then
	info_text "Redirecting to $repo_url..."
	giturl "https://github.com/$repo_url"

elif [ "$1" = "branch" ]; then
	info_text "Redirecting to $branch on $repo_url..."
	giturl "https://github.com/$repo_url/tree/$branch"
	
elif [ "$1" = "nbranch" ]; then
	if arggt "1" ; then
		npush $2
	else
		info_text "Provide a branch name:"
		read name
		if [ "$name" != "" ]; then
			npush $name
		else
			error_text "Invalid branch name"
		fi
	fi
	
elif [ "$1" = "pr" ]; then
	info_text "Creating PR for $branch in $repo_url..."
	giturl "https://github.com/$repo_url/pull/new/$branch"
	
elif [ "$1" = "bpr" ]; then
	if is_git_repo ; then
		if arggt "1" ; then
			bpr $2
		else
			info_text "Provide a branch name:"
			read name
			if [ "$name" != "" ]; then
				bpr $name
			fi
		fi
	fi


# FILE CREATION

elif [[ "${exts[*]}" =~ "$1" ]]; then
	info_text "Enter a filename for your $1 file:"
	read fname
	info_text "Creating $fname.$1"
	touch $fname.$1
    if mac; then
        open -a Xcode $fname.$1
    else
        gedit $fname.$1
    fi

	
# ERROR

else
	error_text "Invalid command! Try again"
fi
