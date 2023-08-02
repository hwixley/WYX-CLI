#!/bin/bash

# CLI CONSTS
version="1.0.0"
num_args=$#
mypath=$(readlink -f "${BASH_SOURCE:-$0}")
date=$(date)
year="${date:24:29}"

mydir=$(dirname "$mypath")
datadir=$mydir/.wix-cli-data
scriptdir=$mydir/scripts

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

clipboard() {
	if command -v pbcopy >/dev/null 2>&1; then
		info_text "This has been saved to your clipboard!"
		echo "$1" | pbcopy
	elif command -v xclip >/dev/null 2>&1; then
		info_text "This has been saved to your clipboard!"
		echo "$1" | xclip -selection c
	else
		warn_text "Clipboard not supported on this system, please install xclip or pbcopy."
	fi
}

editfile() {
    if using_zsh; then
        vi "$1"
    else
        gedit "$1"
    fi
}

arggt() {
	if [ "$num_args" -gt "$1" ]; then
		return 0
	else
		return 1
	fi	
}

direxists() {
	if [[ -v mydirs[$1] ]]; then
		return 0
	else
		return 1
	fi
}

orgexists() {
	if [[ -v myorgs[$1] ]]; then
		return 0
	else
		return 1
	fi
}

scriptexists() {
	if [[ -v myscripts[$1] ]]; then
		return 0
	else
		return 1
	fi
}

is_git_repo() {
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


commit() {
	git add .
	if empty "$1" ; then
		if [ -f "${datadir}/.env" ]; then
			if grep -q "OPENAI_API_KEY=" "${datadir}/.env" && grep -q "USE_SMART_COMMIT=true" "${datadir}/.env" ; then
				IFS=$'\n' lines=($(python3 "$scriptdir/services/openai_service.py" "smart"))
				h2_text "GPT-3 Suggestion"
				if using_zsh; then
					h2_text "Title:${RESET}	${lines[1]}"
					h2_text "Description:${RESET} ${lines[2]}"
					echo ""
					info_text "Press enter to use this suggestion or type your own description."
					read -r description
					git commit -m "${description:-${lines[1]}}" -m "${lines[2]}"
				else
					h2_text "Title:${RESET}	${lines[0]}"
					h2_text "Description:${RESET} ${lines[1]}"
					echo ""
					info_text "Press enter to use this suggestion or type your own description."
					read -r description
					git commit -m "${description:-${lines[0]}}" -m "${lines[1]}"
				fi
			else
				info_text "Provide a commit description: (defaults to 'wix-cli quick commit')"
				read -r description
				git commit -m "${description:-wix-cli quick commit}"
			fi
		else
			info_text "Provide a commit description: (defaults to 'wix-cli quick commit')"
			read -r description
			git commit -m "${description:-wix-cli quick commit}"
		fi
	else
		git commit -m "${1:-wix-cli quick commit}"
	fi
}

push() {
	if [ "$1" != "$branch" ]; then
		git checkout "$1"
	fi
	commit "$2"
	git push origin "$1"
}

npush() {
	git checkout -b "$1"
	commit "$2"
	git push origin "$1"
}

pull() {
	if [ "$1" != "$branch" ]; then
		git checkout "$1"
	fi
	git pull origin "$1"
}

bpr() {
	npush "$1"
	info_text "Creating PR for $branch in $repo_url..."
	openurl "https://github.com/$repo_url/pull/new/$1"
}

ginit() {
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
wix_cd() {
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

wix_new() {
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

wix_run() {
	if scriptexists "$1"; then
		info_text "Running $1 script!"
		source "$datadir/run-configs/${myscripts[$1]}.sh"
	else
		error_text "This is only supported for gs currently"
	fi
}

wix_delete() {
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
wix_ginit() {
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
				ginit "${user[username]}" "$2" "new"
			fi
		else
			ginit "${user[username]}" "$2" "new"
		fi
	else
		error_text "This is already a git repository..."
	fi
}

wix_gnew() {	
	if wix_new "$1" "$2" ; then
		wix_ginit "$1" "$2"
	fi
}

giturl() {
	if is_git_repo ; then
		openurl "$1"
	fi
}


# AUTO UPDATE CLI

wix_update() {
	# if ! empty "$1" ; then
	# 	if [ "$1" = "force" ] ; then
	# 		info_text "Forcing update..."
	# 		git pull origin master
	# 		return 0
	# 	fi
	# fi
	info_text "Checking for updates..."
	git fetch
	# pull "$branch"
	UPSTREAM=${1:-'@{u}'}
	LOCAL=$(git rev-parse @)
	REMOTE=$(git rev-parse "$UPSTREAM")
	BASE=$(git merge-base @ "$UPSTREAM")

	if [ "$LOCAL" = "$REMOTE" ]; then
		info_text "Up-to-date"
	elif [ "$LOCAL" = "$BASE" ]; then
		info_text "Updating..."
		pull "$branch"
		(source "$mypath" "${@:1}" && exit) || error_text "Failed to source $mypath..."
	elif [ "$REMOTE" = "$BASE" ]; then
		echo "Need to push"
	else
		echo "Diverged"
	fi
	echo ""
}

# {
# 	wix_update ""
# } &> /dev/null

wix_update ""
warn_text "Testing..."

# DEFAULT


if [ $num_args -eq 0 ]; then
	echo "Welcome to the..."
	echo ""
	info_text " ${CYAN}Y${BLUE}8b ${CYAN}Y${BLUE}8b ${CYAN}Y${BLUE}888P ${CYAN}8${BLUE}88 ${CYAN}Y${BLUE}8b Y8P${GREEN}     e88'Y88 888     888 "
	info_text "  ${CYAN}Y${BLUE}8b ${CYAN}Y${BLUE}8b ${CYAN}Y${BLUE}8P  ${CYAN}8${BLUE}88  ${CYAN}Y${BLUE}8b Y${GREEN}     d888  'Y 888     888 "
	info_text "   ${CYAN}Y${BLUE}8b ${CYAN}Y${BLUE}8b ${CYAN}Y${BLUE}   ${CYAN}8${BLUE}88   ${CYAN}Y${BLUE}8b${GREEN}     C8888     888     888 "
	info_text "    ${CYAN}Y${BLUE}8b ${CYAN}Y${BLUE}8b    ${CYAN}8${BLUE}88  e ${CYAN}Y${BLUE}8b${GREEN}     Y888  ,d 888  ,d 888 "
	info_text "     ${CYAN}Y${BLUE}8P ${CYAN}Y${BLUE}     ${CYAN}8${BLUE}88 d8b ${CYAN}Y${BLUE}8b${GREEN}     \"88,d88 888,d88 888 "
	echo ""
	echo "v$version"
	echo ""
	h1_text	"MAINTENANCE:"
	echo "- sys-info			${ORANGE}: view shell info${RESET}"
	echo "- update			${ORANGE}: update wix-cli${RESET}"
	echo "- install-deps			${ORANGE}: install dependencies${RESET}"
	echo ""
	h1_text "DIRECTORY NAVIGATION:"
	echo "- cd <mydir> 			${ORANGE}: navigation${RESET}"
	echo "- back 				${ORANGE}: return to last dir${RESET}"
	echo ""
	# echo ""
	# h1_text "DIR MANAGEMENT:"
	# echo "- new <mydir> <subdir>		${ORANGE}: new directory${RESET}"
	# echo "- delete <mydir> <subdir> 	${ORANGE}: delete dir${RESET}"
	# echo "- hide <mydir> <subdir>		${ORANGE}: hide dir${RESET}"
	h1_text "CODE:"
	echo "- vsc <mydir>			${ORANGE}: open directory in Visual Studio Code${RESET}"
	if using_zsh; then
		echo "- xc <mydir>			${ORANGE}: open directory in XCode${RESET}"
	fi
	echo "- run <myscript> 		${ORANGE}: setup and run environment${RESET}"
	echo ""
	h1_text "GITHUB AUTOMATION:"
	echo "- push <branch?>		${ORANGE}: push changes to repo branch${RESET}"
	echo "- pull <branch?>		${ORANGE}: pull changes from repo branch${RESET}"
	# echo "- pullr [<repo:branch>]?	${ORANGE}: pull changes from respective repo and branch combinations${RESET}"
	echo "- ginit <newdir?>		${ORANGE}: setup git repo in existing/new directory${RESET}"
	# echo "- gnew <mydir/org> <repo> 	${ORANGE}: create and init git repo${RESET}"
	echo "- nb <name?>			${ORANGE}: create new branch${RESET}"
	echo "- pr 				${ORANGE}: create PR for branch${RESET}"
	echo "- bpr 				${ORANGE}: checkout changes to new branch and create PR${RESET}"
	echo "- commits			${ORANGE}: view commit history${RESET}"
	echo "- lastcommit			${ORANGE}: view last commit${RESET}"
	echo "- setup smart_commit		${ORANGE}: setup smart commit${RESET}"
	echo ""
	h1_text "URLS:"
	echo "- repo 				${ORANGE}: go to git repo URL${RESET}"
	echo "- branch 			${ORANGE}: go to git branch URL${RESET}"
	echo "- prs 				${ORANGE}: go to git repo Pull Requests URL${RESET}"
	echo "- actions 			${ORANGE}: go to git repo Actions URL${RESET}"
	echo "- issues 			${ORANGE}: go to git repo Issues URL${RESET}"
	echo "- notifs			${ORANGE}: go to git notifications URL${RESET}"
	echo "- profile			${ORANGE}: go to git profile URL${RESET}"
	echo "- org <myorg?>			${ORANGE}: go to git org URL${RESET}"
	echo "- help				${ORANGE}: go to wix-cli GitHub Pages URL${RESET}"
	echo ""
	h1_text "MY DATA:"
	echo "- user 				${ORANGE}: view your user-specific data (ie. name, GitHub username)${RESET}"
	echo "- myorgs 			${ORANGE}: view your GitHub organizations and their aliases${RESET}"
	echo "- mydirs 			${ORANGE}: view your directory aliases${RESET}"
	echo "- myscripts 			${ORANGE}: view your script aliases${RESET}"
	echo "- todo				${ORANGE}: view your to-do list${RESET}"
	echo ""
	h1_text "MANAGE MY DATA:"
	echo "- editd <data> 			${ORANGE}: edit a piece of your data (ie. user, myorgs, mydirs, myscripts, todo)${RESET}"
	echo "- edits <myscript> 		${ORANGE}: edit a script (you must use an alias present in myscripts)${RESET}"
	echo "- newscript <script-name?>	${ORANGE}: create a new script${RESET}"
	echo ""
	h1_text "FILE UTILITIES:"
	echo "- fopen				${ORANGE}: open current directory in files application${RESET}"
	echo "- find \"<fname>.<fext>\"		${ORANGE}: find a file inside the current directory with the respective name${RESET}"
	echo "- regex \"<regex?>\" \"<fname?>\"	${ORANGE}: return the number of regex matches in the given file${RESET}"
	echo "- rgxmatch \"<regex?>\" \"<fname?>\"${ORANGE}: return the string matches of your regex in the given file${RESET}"
	echo ""
	h1_text "NETWORK UTILITIES:"
	echo "- ip				${ORANGE}: get local and public IP addresses of your computer${RESET}"
	echo "- wifi				${ORANGE}: list information on your available wifi networks${RESET}"
	echo "- wpass				${ORANGE}: list your saved wifi passwords${RESET}"
	echo "- speedtest			${ORANGE}: run a network speedtest${RESET}"
	echo "- hardware-ports		${ORANGE}: list your hardware ports${RESET}"
	echo ""
	h1_text "IMAGE UTILITIES:"
	echo "- genqr <url?> <fname?>		${ORANGE}: generate a png QR code for the specified URL${RESET}"
	echo "- upscale <fname?> <scale?>	${ORANGE}: upscale an image's resolution (**does not smooth interpolated pixels**)${RESET}"
	echo ""
	h1_text "TEXT UTILITIES:"
	echo "- genhex <hex-length?>		${ORANGE}: generate and copy pseudo-random hex string (of default length 32)${RESET}"
	echo "- genb64 <base64-length?>	${ORANGE}: generate and copy pseudo-random base64 string (of default length 32)${RESET}"
	echo "- copy <string?|cmd?> 		${ORANGE}: copy a string or the output of a shell command (using \$(<cmd>) syntax) to your clipboard${RESET}"
	echo ""
	h1_text	"MISC UTILITIES:"
	echo "- weather <city?>		${ORANGE}: get the weather forecast for your current location${RESET}"
	echo "- moon				${ORANGE}: get the current moon phase${RESET}"
	echo ""
	h1_text "HELP UTILITIES:"
	echo "- explain \"<cmd?>\"		${ORANGE}: explain the syntax of the input bash command${RESET}"
	echo ""

	# h1_text "CLI management:"
	# echo "- edit"
	# echo "- save"
	# echo "- cat"
	# echo "- version"
	# echo "- cdir"


# GENERAL

elif [ "$1" = "sys-info" ]; then
	if using_zsh; then
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
	clipboard "$truncated_pass"

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
	clipboard "$truncated_pass"

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

elif [ "$1" = "mpull" ]; then
	if [ "$(git branch --list master)" ]; then
		pull "master"
	elif [ "$(git branch --list main)" ]; then
		pull "main"
	else
		warn_text "No master or main branch found..."
	fi

elif [ "$1" = "repo" ]; then
	info_text "Redirecting to $repo_url..."
	giturl "https://github.com/$repo_url"

elif [ "$1" = "branch" ]; then
	info_text "Redirecting to $branch on $repo_url..."
	giturl "https://github.com/$repo_url/tree/$branch"

elif [ "$1" = "actions" ]; then
	info_text "Redirecting to Action Workflows on $repo_url..."
	giturl "https://github.com/$repo_url/actions"

elif [ "$1" = "issues" ]; then
	info_text "Redirecting to Issues on $repo_url..."
	giturl "https://github.com/$repo_url/issues"

elif [ "$1" = "prs" ]; then
	info_text "Redirecting to Pull Requests on $repo_url..."
	giturl "https://github.com/$repo_url/pulls"

elif [ "$1" = "notifs" ]; then
	info_text "Redirecting to your Notifications..."
	giturl "https://github.com/notifications"

elif [ "$1" = "commits" ]; then
	git log --pretty=format:"${GREEN}%H${RESET} - ${BLUE}%an${RESET}, ${ORANGE}%ar${RESET} : %s"

elif [ "$1" = "lastcommit" ]; then
	clipboard $(git rev-parse HEAD)
	git show HEAD

elif [ "$1" = "nb" ]; then
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
	openurl "https://github.com/${user[username]}"

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

elif [ "$1" = "newscript" ]; then
	name="$2"
	if ! arggt "1"; then
		info_text "What would you like to call your script? (no spaces)"
		read -r name_prompt
		name="$name_prompt"
	fi
	if [ -f "$datadir/$name.sh" ]; then
		error_text "Error: this script name already exists"
	else
		info_text "Creating new script..."
		echo "$name=$name" >> "$datadir/run-configs.txt"
		touch "$datadir/run-configs/$name.sh"
		editfile "$datadir/run-configs/$name.sh"
	fi

# FILE CREATION

elif [ "$1" = "newf" ]; then
	fext="sh"
	if arggt "1"; then
		fext="$2"
	else
		info_text "Enter the file extension you would like to use:"
		read -r fext
	fi
	if [[ "${exts[*]}" =~ $fext ]]; then
		info_text "Enter a filename for your $1 file:"
		read -r fname
		info_text "Creating $fname.$1"
		touch "$fname.$1"
		editfile "$fname.$1"
	fi

# FIND FILE

elif [ "$1" = "find" ]; then
	if arggt "1"; then
		find . -type f -name "$2"
	else
		info_text "Enter the filename you would like to find:"
		read -r fname
		find . -type f -name "$fname"
	fi

# CLIPBOARD

elif [ "$1" = "copy" ]; then
	if arggt "1"; then
		if [[ "$2" =~ ^\$\(.*\)$ ]]; then
			DATA="$2"
			clipboard "$DATA"
		else
			clipboard "$2"
		fi
	else
		info_text "Enter the text you would like to copy to your clipboard:"
		read -r text
		clipboard "$text"
	fi

# IP ADDRESS

elif [ "$1" = "ip" ]; then
	echo ""
	info_text "Local IPs:"
	if mac; then
		ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk '{print $2}'
	else
		hostname -I
	fi
	echo ""
	info_text "Public IP:"
	public_ip=$(curl ifconfig.co/json)
	ip=$(echo "$public_ip" | jq -r '.ip')
	city=$(echo "$public_ip" | jq -r '.city')
	region=$(echo "$public_ip" | jq -r '.region_name')
	zip=$(echo "$public_ip" | jq -r '.zip_code')
	country=$(echo "$public_ip" | jq -r '.country')
	lat=$(echo "$public_ip" | jq -r '.latitude')
	long=$(echo "$public_ip" | jq -r '.longitude')
	time_zone=$(echo "$public_ip" | jq -r '.time_zone')
	asn_org=$(echo "$public_ip" | jq -r '.asn_org')
	echo ""
	echo "IP: $ip"
	echo ""
	echo "${ORANGE}Address:${RESET} $city, $region, $zip, $country"
	echo "${ORANGE}Latitude & Longitude:${RESET} ($lat, $long)"
	echo "${ORANGE}Timezone:${RESET} $time_zone"
	echo "${ORANGE}ASN Org:${RESET} $asn_org"
	
	echo ""
	info_text "Eth0 MAC Address:"
	if mac; then
		ifconfig en1 | awk '/ether/{print $2}'
	else
		cat "/sys/class/net/$(ip route show default | awk '/default/ {print $5}')/address"
	fi
	echo ""

elif [ "$1" = "wifi" ]; then
	if mac; then
		/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport scan
	else
		python3 "${scriptdir}/wifi_sniffer.py"
	fi

elif [ "$1" = "hardware-ports" ]; then
	if mac; then
		networksetup -listallhardwareports
	else
		echo "Not supported on this OS"
	fi

elif [ "$1" = "wpass" ]; then
	if mac; then
		info_text "Enter the SSID of the network you would like to get the password for:"
		read -r ssid
		info_text "Getting password for $ssid..."
		security find-generic-password -ga "$ssid" | grep "password:"
		echo ""
	else
		info_text "Listing saved Wifi passwords:"
		sudo grep -r '^psk=' /etc/NetworkManager/system-connections/
	fi

elif [ "$1" = "speedtest" ]; then
	info_text "Running speedtest..."
	speedtest

# QR CODE

elif [ "$1" = "genqr" ]; then
	link="$2"
	fname="$3"
	if ! arggt "1"; then
		info_text "Enter the URL you would like to link to:"
		read -r url
		link="$url"

		if ! arggt "2"; then
			info_text "Enter the name for your QR code:"
			read -r qrname
			fname="$qrname"
		fi
	fi
	info_text "Generating a QR code..."
	qrencode -o "$fname.png" "$link"
	display "$fname.png"

# UPSCALE PHOTO

elif [ "$1" = "upscale" ]; then
	fname="$2"
	alpha="$3"
	if ! arggt "1"; then
		info_text "Enter the file you would like to upscale:"
		read -r url
		fname="$url"

		if ! arggt "2"; then
			info_text "Enter the scale multiplier:"
			read -r mult
			alpha="$mult"
		fi
	fi
	info_text "Upscaling $fname..."
	python3 "$scriptdir/photo-upscale.py" "$fname" "$alpha"

# OPEN FILE

elif [ "$1" = "fopen" ]; then
	if arggt "1"; then
		dir="$2"
		if direxists "$dir"; then
			mydir="${mydirs[$dir]/\~/${HOME}}"
			info_text "Opening $mydir..."
			openfile "$mydir"
		else
			error_text "Directory alias does not exist"
		fi
	else
		info_text "Opening current directory..."
		openfile "$(pwd)"
	fi

# REGEX SEARCH

elif [ "$1" = "regex" ]; then
	if arggt "1"; then
		regex="$2"
		if arggt "2"; then
			fname="$3"
			if [ -f "$fname" ]; then
				info_text "Searching for $regex in $fname..."
				info_text "Number of matches:"
				grep -E "$regex" "$fname" | wc -l
			else
				error_text "File does not exist"
			fi
		else
			info_text "Enter the filename you would like to search:"
			read -r fname
			if [ -f "$fname" ]; then
				info_text "Searching for $regex in $fname..."
				info_text "Number of matches:"
				grep -E "$regex" "$fname" | wc -l
			else
				error_text "File does not exist"
			fi
		fi
	else
		info_text "Enter the regex you would like to search for:"
		read -r regex
		info_text "Enter the filename you would like to search:"
		read -r fname
		if [ -f "$fname" ]; then
			info_text "Searching for $regex in $fname..."
			grep -E "$regex" "$fname"
		else
			error_text "File does not exist"
		fi
	fi

elif [ "$1" = "rgxmatch" ]; then
	if arggt "1"; then
		regex="$2"
		if arggt "2"; then
			fname="$3"
			if [ -f "$fname" ]; then
				info_text "Searching for $regex in $fname..."
				echo ""
				info_text "Matches: "
				data=$(cat "$fname")
				[[ "$data" =~ $regex ]]
				token=$(echo "${BASH_REMATCH[1]}")
				echo "$token"
				clipboard "$token"
			else
				error_text "File does not exist"
			fi
		else
			info_text "Enter the filename you would like to search:"
			read -r fname
			if [ -f "$fname" ]; then
				info_text "Searching for $regex in $fname..."
				echo ""
				info_text "Matches: "
				data=$(cat "$fname")
				[[ "$data" =~ $regex ]]
				token=$(echo "${BASH_REMATCH[1]}")
				echo "$token"
				clipboard "$token"
			else
				error_text "File does not exist"
			fi
		fi
	else
		info_text "Enter the regex you would like to search for:"
		read -r regex
		info_text "Enter the filename you would like to search:"
		read -r fname
		if [ -f "$fname" ]; then
			info_text "Searching for $regex in $fname..."
			grep -E "$regex" "$fname" | wc -l
		else
			error_text "File does not exist"
		fi
	fi

# MISC UTILITIES

elif [ "$1" = "weather" ]; then
	if arggt "1"; then
		city="$2"
		info_text "Getting weather for $city..."
		curl wttr.in/"$city"
	else
		info_text "Getting weather for your current location..."
		curl wttr.in
	fi

elif [ "$1" = "moon" ]; then
	info_text "Getting moon phase..."
	curl wttr.in/moon

elif [ "$1" = "leap-year" ]; then
	if [[ "$year" =~ ^[0-9]*00$ ]]; then
		if [ "$((year % 400))" -eq 0 ]; then
			info_text "$year is a leap year"
		else
			info_text "$year is not a leap year"
		fi
	elif [ "$((year % 4))" -eq 0 ]; then
		info_text "$year is a leap year"
	else
		info_text "$year is not a leap year"
	fi
	next_one=$((year + 4 - (year % 4)))
	info_text "The next leap year is $next_one"



# HELP UTILITIES

elif [ "$1" = "explain" ]; then
	if arggt "1"; then
		cmd="$2"
		info_text "Finding explanation for $cmd..."
		cmd="${cmd// /+}"
		openurl "https://explainshell.com/explain?cmd=$cmd"
	else
		info_text "Enter the command you would like to explain:"
		read -r cmd
		info_text "Finding explanation for $cmd..."
		cmd="${cmd// /+}"
		openurl "https://explainshell.com/explain?cmd=$cmd"
	fi

# UPDATE

elif [ "$1" = "update" ]; then
	cd $mydir
	git pull origin master
	cd -

elif [ "$1" = "install-deps" ]; then
	if ! using_zsh; then
		info_text "Installing dependencies..."
		sudo apt-get install xclip
		curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
		sudo apt-get install speedtest
	fi

	if mac; then
		info_text "Installing dependencies..."
		brew install xclip jq
		brew tap teamookla/speedtest
		brew install speedtest --force
	fi

	info_text "Installing python dependencies..."
	pip3 install -r requirements.txt

# EXTRA FEATURE SETUP

elif [ "$1" = "setup" ]; then
	if [ "$2" = "smart_commit" ]; then
		info_text "Setting up smart commit..."
		echo ""
		info_text "Enter an OpenAI API key:"
		read -r apikey
		echo ""
		rm -rf "${datadir}/.env"
		{ echo "OPENAI_API_KEY=$apikey"; echo "USE_SMART_COMMIT=true"; } >> "${datadir}/.env"
		info_text "You are done!"
	else
		error_text "Invalid command! Try again"
		echo "Type 'wix' to see the list of available commands (and their arguments), or 'wix help' to be redirected to more in-depth online documentation"
	fi

# ERROR

else
	error_text "Invalid command! Try again"
	echo "Type 'wix' to see the list of available commands (and their arguments), or 'wix help' to be redirected to more in-depth online documentation"
fi
