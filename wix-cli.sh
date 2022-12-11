#!/bin/bash

# COLORS
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
RESET=$(tput setaf 7)

# CLI CONSTS
num_args=$#
mypath=~/Documents/random-coding-projects/bashing/wix-cli.sh

# GIT CONSTS
branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
remote=$(git config --get remote.origin.url | sed 's/.*\/\([^ ]*\/[^.]*\).*/\1/')
repo_url=${remote#"git@github.com:"}
repo_url=${repo_url%".git"}

declare -A myorgs
myorgs["gs"]="getskooled"

# DIR CONSTS
insertline=23

declare -A mydirs
mydirs["docs"]=~/Documents
mydirs["self"]=~/Documents/random-coding-projects/bashing
mydirs["gs"]=~/Documents/GetSkooled
mydirs["gs-website"]=${mydirs["gs"]}/website/GetSkooled-MVP-Website
mydirs["down"]=~/Downloads
mydirs["pix"]=~/Pictures
mydirs["rcp"]=~/Documents/random-coding-projects

diraliases=$(echo ${!mydirs[@]} | sed 's/ / - /g' )

# FILE EXTs
exts=("sh" "txt" "py")

# PROMPTS
notsupported="${RED}That path is not supported try: $diraliases"

# FUNCTIONS
function info_text() {
	echo "${GREEN}$1${RESET}"
}

function error_text() {
	if [ "$1" = "" ]; then
		echo $notsupported
	else
		echo "${RED}$1${RESET}"
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
	if [ -v mydirs[$1] ]; then
		return 0
	else
		return 1
	fi
}

function commit() {
	git add .
	git commit -m "${1:-wix-cli quick commit}"
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
	xdg-open "https://github.com/$repo_url/pull/new/$branch"
}

function openurl() {
	info_text "$1..."
	xdg-open $2
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
	echo "- cd <cdir> 		: navigation"
	echo "- back 			: return to last dir"
	echo "- new <cdir> 		: new directory"
	echo "- run <cdir> 		: setup and run environment"
	echo "- delete <cdir> 	: delete dir"
	echo ""
	info_text "GITHUB AUTOMATION:"
	echo "- push <branch?>	: push changes"
	echo "- ginit			: init git repo"
	echo "- ngit <cdir>	 	: create and init git repo"
	echo "- repo 			: go to repo url"
	echo "- branch 		: go to branch url"
	echo "- nbranch 		: create new branch"
	echo "- pr 			: create PR for branch"
	echo "- bpr 			: checkout changes and create PR for branch"
	echo ""
	info_text "CLI management:"
	echo "- edit"
	echo "- save"
	echo "- cat"
	echo "- cdir"
	echo "- mydirs"


# GENERAL

elif [ "$1" = "cd" ]; then
	if arggt "1" ; then
		if direxists $2 ; then
			info_text "Travelling to -> ${mydirs[$2]}"
			cd ${mydirs[$2]}
		else
			error_text
		fi
	else
		info_text "Where do you want to go?"
		read dir
		if direxists $dir ; then
			echo "${GREEN}Travelling to -> ${mydirs[$dir]}"
			cd ${mydirs[$dir]}
		else
			error_text
		fi
	fi
elif [ "$1" = "new" ]; then
	if [ "$2" = "gs" ]; then
		info_text "Generating new GetSkooled dir ($gs_path/$3)..."
		mkdir $gs_path/$3
		cd $gs_path/$3
	else
		error_text "This is only supported for gs currently"
	fi
	
elif [ "$1" = "run" ]; then
	if [ "$2" = "gs" ]; then
		info_text "Running GetSkooled localhost server on develop"
		cd $gs_path/website/GetSkooled-MVP-Website
		git checkout develop
		git pull origin develop
		php -S localhost:8081
	else
		error_text "This is only supported for gs currently"
	fi
	
elif [ "$1" = "delete" ]; then
	if [ "$2" = "gs" ]; then
		error_text "Are you sure you want to delete $gs_path/$3? [ Yy / Nn]"
		read response
		if [ $response = "y" ] || [ $response = "Y" ]
		then
			error_text "Are you really sure you want to delete $gs_path/$3? [ Yy / Nn]${RESET}"
			read response
			if [ $response = "y" ] || [ $response = "Y" ]
			then
				error_text "Deleting $gs_path/$3"
				rm -rf $gs_path/$3
			fi
		fi
	else
		error_text "This is only supported for gs currently"
	fi
	

# CLI MANAGEMENT

elif [ "$1" = "edit" ]; then
	info_text "Edit wix-cli script..."
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
	for x in "${!mydirs[@]}"; do printf "[%s]=%s\n" "$x" "${mydirs[$x]}" ; done
	

# GITHUB AUTOMATION

elif [ "$1" = "gnew" ]; then
	if [ "$2" = "gs" ]; then
		info_text "Generating new GetSkooled dir ($gs_path/$3)..."
		mkdir $gs_path/$3
		cd $gs_path/$3
		echo "# $3" >> README.md
		git init
		commit "first commit"
		git remote add origin git@github.com:getskooled/$3.git
		openurl "https://github.com/organizations/getskooled/repositories/new"
	else
		error_text "This is only supported for gs currently"
	fi
	
elif [ "$1" = "ginit" ]; then
	info_text "Initializing git repo..."
	git init
	commit "first commit"
	
	if arggt "1" ; then
		if [ -v myorgs[$2] ]; then
			if arggt "2" ; then
				git remote add origin "git@github.com:${myorgs[$2]}/$3.git"
			else
				info_text "Provide a repo name:"
				read name
				git remote add origin "git@github.com:${myorgs[$2]}/$name.git"
			fi
			xdg-open "https://github.com/organizations/${myorgs[$2]}/repositories/new"
		else
			git remote add origin "git@github.com:hwixley/$2.git"
			xdg-open "https://github.com/new"
		fi
	else
		info_text "Provide a repo name:"
		read name
		git remote add origin git@github.com:hwixley/$name.git
		xdg-open https://github.com/new
	fi
	
elif [ "$1" = "push" ]; then
	if arggt "1" ; then
		info_text "Provide a commit description:"
		read description
		push $2 $description
	else
		info_text "Provide a commit description:"
		read description
		push $branch $description
	fi
elif [ "$1" = "repo" ]; then
	openurl "Redirecting to $repo_url" "https://github.com/$repo_url"

elif [ "$1" = "branch" ]; then
	openurl "Redirecting to $branch on $repo_url" "https://github.com/$repo_url/tree/$branch"

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
	openurl "Creating PR for $branch in $repo_url" "https://github.com/$repo_url/pull/new/$branch"
	
elif [ "$1" = "bpr" ]; then
	if arggt "1" ; then
		bpr $2
	else
		info_text "Provide a branch name:"
		read name
		if [ "$name" != "" ]; then
			bpr $name
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
	error_text "Invalid command! Try again"
fi
