#!/bin/bash

source ./functions.sh

# CLI CONSTS
num_args=$#
mypath=$(readlink -f "${BASH_SOURCE:-$0}")
mydir=$(dirname "$mypath")
datadir=$mydir/.wix-cli-data

# DATA
declare -A user
readarray -t lines < "$datadir/git-user.txt"
for line in "${lines[@]}"; do
	key=${line%%=*}
	value=${line#*=}
	user[$key]=$value
done

declare -A myorgs
readarray -t lines < "$datadir/git-orgs.txt"
for line in "${lines[@]}"; do
	key=${line%%=*}
	value=${line#*=}
	myorgs[$key]=$value
done

declare -A mydirs
readarray -t lines < "$datadir/dir-aliases.txt"
for line in "${lines[@]}"; do
	key=${line%%=*}
	value=${line#*=}
	mydirs[$key]=$value
done

declare -A myscripts
readarray -t lines < "$datadir/run-configs.txt"
for line in "${lines[@]}"; do
	key=${line%%=*}
	value=${line#*=}
	myscripts[$key]=$value
done

branch=""
if git rev-parse --git-dir > /dev/null 2>&1; then
	branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
fi
remote=$(git config --get remote.origin.url | sed 's/.*\/\([^ ]*\/[^.]*\).*/\1/')
repo_url=${remote#"git@github.com:"}
repo_url=${repo_url%".git"}


# MODULAR FUNCTIONS

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
	push $1
	info_text "Creating PR for $branch in $repo_url..."
	openurl "https://github.com/$repo_url/pull/new/$branch"
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
			destination=${mydirs[$1]}
			if ! empty $2 ; then
				destination=${mydirs[$1]}/$2
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
	if [ "$1" = "gs" ]; then
		info_text "Running GetSkooled localhost server on develop"
		cd $gs_path/website/GetSkooled-MVP-Website
		git checkout develop
		git pull origin develop
		php -S localhost:8081
	else
		error_text "This is only supported for gs currently"
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
	info_text " ${CYAN}Y${BLUE}8b ${CYAN}Y${BLUE}8b ${CYAN}Y${BLUE}888P ${CYAN}8${BLUE}88 ${CYAN}Y${BLUE}8b Y8P${GREEN}     e88'Y88 888     888 "
	info_text "  ${CYAN}Y${BLUE}8b ${CYAN}Y${BLUE}8b ${CYAN}Y${BLUE}8P  ${CYAN}8${BLUE}88  ${CYAN}Y${BLUE}8b Y${GREEN}     d888  'Y 888     888 "
	info_text "   ${CYAN}Y${BLUE}8b ${CYAN}Y${BLUE}8b ${CYAN}Y${BLUE}   ${CYAN}8${BLUE}88   ${CYAN}Y${BLUE}8b${GREEN}     C8888     888     888 "
	info_text "    ${CYAN}Y${BLUE}8b ${CYAN}Y${BLUE}8b    ${CYAN}8${BLUE}88  e ${CYAN}Y${BLUE}8b${GREEN}     Y888  ,d 888  ,d 888 "
	info_text "     ${CYAN}Y${BLUE}8P ${CYAN}Y${BLUE}     ${CYAN}8${BLUE}88 d8b ${CYAN}Y${BLUE}8b${GREEN}     \"88,d88 888,d88 888 "
	# info_text " ██╗    ██╗██╗██╗  ██╗     ██████╗██╗     ██╗ "
	# info_text " ██║    ██║██║╚██╗██╔╝    ██╔════╝██║     ██║ "
	# info_text " ██║ █╗ ██║██║ ╚███╔╝     ██║     ██║     ██║ "
	# info_text " ██║███╗██║██║ ██╔██╗     ██║     ██║     ██║ "
	# info_text " ╚███╔███╔╝██║██╔╝ ██╗    ╚██████╗███████╗██║ "
	# info_text "  ╚══╝╚══╝ ╚═╝╚═╝  ╚═╝     ╚═════╝╚══════╝╚═╝ "
	echo ""
	echo "v0.0.0.0"
	echo ""
	h1_text "COMMANDS:"
	echo "- cd <cdir> 			${ORANGE}: navigation${RESET}"
	echo "- back 				${ORANGE}: return to last dir${RESET}"
	echo "- new <cdir> <subdir>		${ORANGE}: new directory${RESET}"
	echo "- run <cdir> 			${ORANGE}: setup and run environment${RESET}"
	echo "- delete <cdir> <subdir> 	${ORANGE}: delete dir${RESET}"
	echo ""
	h1_text "GITHUB AUTOMATION:"
	echo "- push <branch?>		${ORANGE}: push changes${RESET}"
	echo "- ginit <org?> <repo>		${ORANGE}: init git repo${RESET}"
	echo "- gnew <cdir/org> <repo> 	${ORANGE}: create and init git repo${RESET}"
	echo "- repo 				${ORANGE}: go to repo url${RESET}"
	echo "- branch 			${ORANGE}: go to branch url${RESET}"
	echo "- nbranch <name?>		${ORANGE}: create new branch${RESET}"
	echo "- pr 				${ORANGE}: create PR for branch${RESET}"
	echo "- bpr 				${ORANGE}: checkout changes and create PR for branch${RESET}"
	echo ""
	h1_text "CLI management:"
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
	warn_text "Edit wix-cli script..."
	gedit $mypath
	info_text "Saving changes to $mypath..."
	source ~/.bashrc
	
elif [ "$1" = "save" ]; then
	info_text "Sourcing bash :)"
	source ~/.bashrc
	
elif [ "$1" = "cat" ]; then
	cat $my_path

elif [ "$1" = "cdir" ]; then
	info_text "Enter an alias for your new directory:"
	read alias
	info_text "Enter the directory:"
	read i_dir
	info_text "Adding $alias=$i_dir to custom dirs"
	sed -i "${insertline}imydirs["$alias"]=$i_dir" $mypath
	wix save
	
elif [ "$1" = "mydirs" ]; then
	for x in $dirkeys; do printf "[%s]=%s\n" "$x" "${mydirs[$x]}" ; done
	

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
	giturl "https://github.com/$repo_url/tree/"
	
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
	gedit $fname.$1	

	
# ERROR

else
	echo "$@"
	error_text "Invalid command! Try again"
fi
