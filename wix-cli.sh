#!/bin/bash

# CLI CONSTS
version="0.0.0.0"
num_args=$#
mypath=$(readlink -f "${BASH_SOURCE:-$0}")
date=$(date)
year="${date:25:29}"

mydir=$(dirname "$mypath")
datadir=$mydir/.wix-cli-data

source $mydir/functions.sh

# DATA
declare -A user
declare -a user_lines user_lines=()
while IFS='' read -r line || [[ -n "$line" ]]; do
    user_lines+=("$line")
done < "$datadir/git-user.txt"
for line in "${user_lines[@]}"; do
	key=${line%%=*}
	value=${line#*=}
	user[$key]=$value
done

declare -A myorgs
declare -a org_lines org_lines=()
while IFS='' read -r line || [[ -n "$line" ]]; do
    org_lines+=("$line")
done < "$datadir/git-orgs.txt"
for line in "${org_lines[@]}"; do
	key=${line%%=*}
	value=${line#*=}
	myorgs[$key]=$value
done

declare -A mydirs
declare -a dir_lines dir_lines=()
while IFS='' read -r line || [[ -n "$line" ]]; do
    dir_lines+=("$line")
done < "$datadir/dir-aliases.txt"
for line in "${dir_lines[@]}"; do
	key=${line%%=*}
	value=${line#*=}
	mydirs[$key]=$value
done

declare -A myscripts
declare -a script_lines script_lines=()
while IFS='' read -r line || [[ -n "$line" ]]; do
    script_lines+=("$line")
done < "$datadir/run-configs.txt"
for line in "${script_lines[@]}"; do
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

function editfile() {
    if zsh; then
        vi "$1"
    else
        gedit "$1"
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

function scriptexists() {
	if [[ -v myscripts[$1] ]]; then
		return 0
	else
		return 1
	fi
}

function is_git_repo() {
	if git rev-parse --git-dir > /dev/null 2>&1; then
		branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
	fi
	if ! empty "$branch" ; then
		return 0
	else
		error_text "This is not a git repository..."
		return 1
	fi
}


function commit() {
	git add .
	if empty "$1" ; then
		info_text "Provide a commit description:"
		read -r description
		git commit -m "${description:-wix-cli quick commit}"
	else
		git commit -m "${1:-wix-cli quick commit}"
	fi
}

function push() {
	if [ "$1" != "$branch" ]; then
		git checkout "$1"
	fi
	commit "$2"
	git push origin "$1"
}

function npush() {
	git checkout -b "$1"
	commit "$2"
	git push origin "$1"
}

function pull() {
	if [ "$1" != "$branch" ]; then
		git checkout "$1"
	fi
	git pull origin "$1"
}

function bpr() {
	push "$1"
	info_text "Creating PR for $branch in $repo_url..."
	openurl "https://github.com/$repo_url/pull/new/$branch"
}

function ginit() {
	git init
	if empty "$2" ; then
		info_text "Provide a name for this repository:"
		read -r rname
		echo "# $rname" >> README.md
		info_text "Would you like to add a MIT license to this repository? [ Yy / Nn ]"
		read -r rlicense
		if [ "$rlicense" = "y" ] || [ "$rlicense" = "Y" ]
		then
			touch "LICENSE.md"
			echo -e "MIT License\n\nCopyright (c) ${user["name"]} $year\n\nPermission is hereby granted, free of charge, to any person obtaining a copy\nof this software and associated documentation files (the "Software"), to deal\nin the Software without restriction, including without limitation the rights\nto use, copy, modify, merge, publish, distribute, sublicense, and/or sell\ncopies of the Software, and to permit persons to whom the Software is\nfurnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all\ncopies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\nIMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\nFITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\nAUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\nLIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\nOUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE\nSOFTWARE." >> "LICENSE.md"
		fi
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
		if direxists "$1" ; then
			destination="${mydirs[$1]/~/${HOME}}"
			if ! empty "$2" ; then
				destination="${mydirs[$1]/~/${HOME}}/$2"
			fi
			info_text "Travelling to -> $destination"
			eval cd "$destination" || (error_text "The path $destination does not exist" && return 1)
			return 0
		else
			error_text
			return 1
		fi
	else
		info_text "Where do you want to go?"
		read -r dir
		if direxists "$dir" ; then
			info_text "Travelling to -> ${mydirs[$dir]}"
			cd "${mydirs[$dir]:?}" || exit
			return 0
		else
			error_text
			return 1
		fi
	fi
}

function wix_new() {
	if direxists "$1" ; then
		if empty "$2" ; then
			info_text "Provide a name for this directory:"
			read -r dname
			info_text "Generating new dir (${mydirs[$1]}/$dname)..."
			mkdir "${mydirs[$1]:?}/$dname"
			cd "${mydirs[$1]:?}/$dname" || exit
		else
			info_text "Generating new dir (${mydirs[$1]}/$2)..."
			mkdir "${mydirs[$1]:?}/$2"
			cd "${mydirs[$1]:?}/$2" || exit
		fi
		return 0
	else
		error_text
		return 1
	fi
}

function wix_run() {
	if scriptexists "$1"; then
		info_text "Running $1 script!"
		source "$datadir/run-configs/${myscripts[$1]}.sh"
	else
		error_text "This is only supported for gs currently"
	fi
}

function wix_delete() {
	if direxists "$1" ; then
		if empty "$2" ; then
			error_text "You did not provide a path in this directory to delete, try again..."
		else
			error_text "Are you sure you want to delete ${mydirs[$1]}/$2? [ Yy / Nn]"
			read -r response
			if [ "$response" = "y" ] || [ "$response" = "Y" ]
			then
				error_text "Are you really sure you want to delete ${mydirs[$1]}/$2? [ Yy / Nn]"
				read -r response
				if [ "$response" = "y" ] || [ "$response" = "Y" ]
				then
					error_text "Deleting ${mydirs[$1]}/$2"
					rm -rf "${mydirs[$1]:?}/$2"
				fi
			fi
		fi
	else
		error_text
	fi
}

# GITHUB AUTOMATION COMMAND FUNCTIONS
function wix_ginit() {
	if ! empty "$1"; then
		mkdir "$1"
		cd "$1" || return 1
	fi

	if empty "$branch" ; then
		info_text "Would you like you to host this repository under a GitHub organization? [ Yy / Nn ]"
		read -r response
		if [ "$response" = "y" ] || [ "$response" = "Y" ]
		then
			echo ""
			h1_text "Your saved GitHub organization aliases:"
			for key in "${!myorgs[@]}"; do
				echo "$key: ${myorgs[$key]}"
			done
			echo ""
			info_text "Please enter the organization name alias you would like to use:"
			read -r orgalias
			if orgexists "$orgalias" ; then
				ginit "${myorgs[$orgalias]}" "$2" "organizations/${myorgs[$orgalias]}/repositories/new"
			else
				ginit "$user" "$2" "new"
			fi
		else
			ginit "$user" "$2" "new"
		fi
	else
		error_text "This is already a git repository..."
	fi
}

function wix_gnew() {	
	if wix_new "$1" "$2" ; then
		wix_ginit "$1" "$2"
	fi
}

function giturl() {
	if is_git_repo ; then
		openurl "$1"
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
	echo "v$version"
	echo ""
	h1_text "NAVIGATION:"
	echo "- cd <mydir> 			${ORANGE}: navigation${RESET}"
	echo "- back 				${ORANGE}: return to last dir${RESET}"
	echo ""
	h1_text "PSEUDO-RANDOM STRING GENERATION:"
	echo "- genhex <hex-length?>		${ORANGE}: generate and copy pseudo-random hex string (of default length 32)${RESET}"
	echo "- genb64 <base64-length?>	${ORANGE}: generate and copy pseudo-random base64 string (of default length 32)${RESET}"
	# echo ""
	# h1_text "DIR MANAGEMENT:"
	# echo "- new <mydir> <subdir>		${ORANGE}: new directory${RESET}"
	# echo "- delete <mydir> <subdir> 	${ORANGE}: delete dir${RESET}"
	# echo "- hide <mydir> <subdir>		${ORANGE}: hide dir${RESET}"
	echo ""
	h1_text "CODE:"
	echo "- vsc <mydir>			${ORANGE}: open dir in Visual Studio Code${RESET}"
	if zsh; then
		echo "- xc <mydir>			${ORANGE}: open dir in XCode${RESET}"
	fi
	echo "- run <myscript> 		${ORANGE}: setup and run environment${RESET}"
	echo ""
	h1_text "GITHUB AUTOMATION:"
	echo "- push <branch?>		${ORANGE}: push changes to repo branch${RESET}"
	echo "- pull <branch?>		${ORANGE}: pull changes from repo branch${RESET}"
	# echo "- pullr [<repo:branch>]?	${ORANGE}: pull changes from respective repo and branch combinations${RESET}"
	echo "- ginit <newdir?>		${ORANGE}: setup git repo in existing/new directory${RESET}"
	# echo "- gnew <mydir/org> <repo> 	${ORANGE}: create and init git repo${RESET}"
	echo "- nbranch <name?>		${ORANGE}: create new branch${RESET}"
	echo "- pr 				${ORANGE}: create PR for branch${RESET}"
	echo "- bpr 				${ORANGE}: checkout changes to new branch and create PR${RESET}"
	echo ""
	h1_text "URLS:"
	echo "- repo 				${ORANGE}: go to git repo url${RESET}"
	echo "- branch 			${ORANGE}: go to git branch url${RESET}"
	echo "- profile			${ORANGE}: go to git profile url${RESET}"
	echo "- org <myorg?>			${ORANGE}: go to git org url${RESET}"
	echo "- help				${ORANGE}: go to wix-cli GitHub Pages url${RESET}"
	echo ""
	h1_text "MY DATA:"
	echo "- user 				${ORANGE}: view your user-specific data (ie. name, GitHub username)${RESET}"
	echo "- myorgs 			${ORANGE}: view your GitHub organizations and their aliases${RESET}"
	echo "- mydirs 			${ORANGE}: view your directory aliases${RESET}"
	echo "- myscripts 			${ORANGE}: view your script aliases${RESET}"
	echo "- todo				${ORANGE}: view your to-do list${RESET}"
	echo "- editd <data> 			${ORANGE}: edit a piece of your data (ie. user, myorgsm mydirs, myscripts)${RESET}"
	echo "- edits <myscript> 		${ORANGE}: edit a script (you must use an alias present in myscripts)${RESET}"
	echo ""
	# h1_text "CLI management:"
	# echo "- edit"
	# echo "- save"
	# echo "- cat"
	# echo "- version"
	# echo "- cdir"


# GENERAL

elif [ "$1" = "sys-info" ]; then
	if zsh; then
		echo "ZSH (0_0)"
	else
		echo "BASH (-_-)"
	fi

elif [ "$1" = "cd" ]; then
	wix_cd "$2"
	
elif [ "$1" = "back" ]; then
	cd - || error_text "Failed to execute 'cd -'..."
	
elif [ "$1" = "new" ]; then
	wix_new "$2" "$3"
	
elif [ "$1" = "run" ]; then
	wix_run "$2"
	
elif [ "$1" = "vsc" ]; then
	if direxists "$2"; then
		wix_cd "$2"
		info_text "Opening up VSCode editor..."
		code .
	else
		error_text "Error: this directory alias does not exist, please try again"
	fi

elif [ "$1" = "delete" ]; then
	wix_delete "$2" "$3"

elif [ "$1" = "hide" ]; then
	echo "not implemented yet"

elif [ "$1" = "genhex" ]; then
	hex_size=32
	if arggt "1"; then
		if ! [[ "$2" =~ ^[0-9]+$ ]]; then
        	error_text "Error: the hex-length argument must be an integer"
			return 1
		else
			hex_size=$2
		fi
	fi
	pass=$(openssl rand -hex "$hex_size")
	truncated_pass="${pass:0:$hex_size}"
	info_text "Your pseudo-random hex string is: ${RESET}$truncated_pass"
	info_text "This has been saved to your clipboard!"
	echo "$truncated_pass" | xclip -selection c

elif [ "$1" = "genb64" ]; then
	hex_size=32
	if arggt "1"; then
		if ! [[ "$2" =~ ^[0-9]+$ ]]; then
        	error_text "Error: the base64-length argument must be an integer"
			return 1
		else
			hex_size=$2
		fi
	fi
	pass=$(openssl rand -base64 "$hex_size")
	truncated_pass="${pass:0:$hex_size}"
	info_text "Your pseudo-random base64 string is: ${RESET}$truncated_pass"
	info_text "This has been saved to your clipboard!"
	echo "$truncated_pass" | xclip -selection c

# CLI MANAGEMENT

elif [ "$1" = "edit" ]; then
	warn_text "Edit wix-cli script..."
	editfile "$mypath"
	info_text "Saving changes to $mypath..."
	source $(envfile)
	
elif [ "$1" = "save" ]; then
	info_text "Sourcing bash :)"
	source $(envfile)
	
elif [ "$1" = "cat" ]; then
	cat "$mypath"

elif [ "$1" = "-v" ] || [ "$1" = "--version" ] || [ "$1" = "version" ]; then
	echo "v$version"

# elif [ "$1" = "cdir" ]; then
# 	info_text "Enter an alias for your new directory:"
# 	read -r alias
# 	info_text "Enter the directory:"
# 	read -r i_dir
# 	info_text "Adding $alias=$i_dir to custom dirs"
# 	sed -i "${insertline}imydirs["$alias"]=$i_dir" $mypath
# 	wix save
	
# elif [ "$1" = "mydirs" ]; then
# 	for x in $dirkeys; do printf "[%s]=%s\n" "$x" "${mydirs[$x]}" ; done
	

# GITHUB AUTOMATION

# elif [ "$1" = "gnew" ]; then
# 	wix_gnew "$2" "$3"
	
elif [ "$1" = "ginit" ]; then
	wix_ginit "$2"
	
elif [ "$1" = "push" ]; then
	if arggt "1" ; then
		push "$2"
	else
		push "$branch"
	fi

elif [ "$1" = "pull" ]; then
	if arggt "1" ; then
		pull "$2"
	else
		pull "$branch"
	fi

elif [ "$1" = "repo" ]; then
	info_text "Redirecting to $repo_url..."
	giturl "https://github.com/$repo_url"

elif [ "$1" = "branch" ]; then
	info_text "Redirecting to $branch on $repo_url..."
	giturl "https://github.com/$repo_url/tree/$branch"
	
elif [ "$1" = "nbranch" ]; then
	if arggt "1" ; then
		npush "$2"
	else
		info_text "Provide a branch name:"
		read -r name
		if [ "$name" != "" ]; then
			npush "$name"
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
			bpr "$2"
		else
			info_text "Provide a branch name:"
			read -r name
			if [ "$name" != "" ]; then
				bpr "$name"
			fi
		fi
	fi

elif [ "$1" = "profile" ]; then
	openurl "https://github.com/${user["username"]}"

elif [ "$1" = "org" ]; then
	if arggt "1"; then
		if orgexists "$2"; then
			giturl "https://github.com/${myorgs[$2]}"
		else
			error_text "That organisation does not exist..."
			info_text "Execute 'wix myorgs' to see your saved organisations"
		fi
	else
		giturl "https://github.com/${myorgs[default]}"
	fi

# URLs

elif [ "$1" = "help" ]; then
	openurl "https://hwixley.github.io/wix-cli"

# MY DATA

elif [ "$1" = "user" ]; then
	cat "$datadir/git-user.txt"

elif [ "$1" = "mydirs" ]; then
	cat "$datadir/dir-aliases.txt"

elif [ "$1" = "myorgs" ]; then
	cat "$datadir/git-orgs.txt"

elif [ "$1" = "myscripts" ]; then
	cat "$datadir/run-configs.txt"

elif [ "$1" = "todo" ]; then
	cat "$datadir/todo.txt"

elif [ "$1" = "editd" ]; then
	data_to_edit="$2"
	if ! arggt "1"; then
		info_text "What data would you like to edit?"
		read -r data_to_edit_prompt
		data_to_edit=$data_to_edit_prompt

		declare -a datanames
		datanames=( "user" "myorgs" "mydirs" "myscripts" )
		if ! printf '%s\0' "${datanames[@]}" | grep -Fxqz -- "$data_to_edit_prompt"; then
			error_text "'$data_to_edit_prompt' is not a valid piece of data, please try one of the following: ${datanames[*]}"
			return 1
		fi
	fi
	if [ "$data_to_edit" = "user" ]; then
		editfile "$datadir/git-user.txt"
	elif [ "$data_to_edit" = "myorgs" ]; then
		editfile "$datadir/git-orgs.txt"
	elif [ "$data_to_edit" = "mydirs" ]; then
		editfile "$datadir/dir-aliases.txt"
	elif [ "$data_to_edit" = "myscripts" ]; then
		editfile "$datadir/run-configs.txt"
	elif [ "$data_to_edit" = "todo" ]; then
		editfile "$datadir/todo.txt"
	fi

elif [ "$1" = "create-script" ]; then
	script_name="$2"
	if ! arggt "1"; then
		info_text "Enter the name of the script you would like to add:"
		read -r script_name_prompt
		script_name=$script_name_prompt
	fi
	fname="$datadir/run-configs/$script_name.sh"
	touch "$fname"
	chmod u+x "$fname"
	editfile "$fname"

elif [ "$1" = "edits" ]; then
	script_to_edit="$2"
	if ! arggt "1"; then
		info_text "What script would you like to edit?"
		read -r script_to_edit_prompt
		script_to_edit=$script_to_edit_prompt
	fi
	if scriptexists "$script_to_edit"; then
		info_text "Editing $script_to_edit script..."
		editfile "$datadir/run-configs/$script_to_edit.sh"
	else
		error_text "This script does not exist... Please try again"
	fi

# FILE CREATION

elif [[ "${exts[*]}" =~ $1 ]]; then
	info_text "Enter a filename for your $1 file:"
	read -r fname
	info_text "Creating $fname.$1"
	touch "$fname.$1"
	editfile "$fname.$1"	

	
# ERROR

else
	error_text "Invalid command! Try again"
	echo "Type 'wix' to see the list of available commands (and their arguments), or 'wix help' to be redirected to more in-depth online documentation"
fi
