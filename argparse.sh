#!/bin/bash

# CLI CONSTS
version="1.1.0"
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

check_keystore() {
	envfile="$datadir/.env"
	if [[ -f "$envfile" ]]; then
		# Check if key-value pair exists in .env file
		if grep -q "^$1=" "$envfile"; then
			# Prompt user to replace the existing value
			read -rp "${GREEN}Key \"$1\" already exists. Do you want to replace the value? (y/n):${RESET} " choice
			if [[ $choice == "y" || $choice == "Y" ]]; then
				if [ -n "$2" ]; then
					# Replace the value in .env
					sed -i "s/^$1=.*/$1=$2/" "$envfile"
					info_text "Value for key \"$1\" replaced successfully!"
				else
					# Prompt user to enter the value
					read -rp "${GREEN}Enter the value for \"$1\":${RESET} " value

					# Replace the value in .env
					sed -i "s/^$1=.*/$1=$value/" "$envfile"
					info_text "Value for key \"$1\" replaced successfully!"
				fi
			else
				info_text "Value for key \"$1\" not replaced."
			fi
		else
			if [ -n "$2" ]; then
				# Append key-value pair to .env
				echo "$1=$2" >> "$envfile"
				info_text "Value for key \"$1\" appended successfully!"
			else
				# Prompt user to enter the value
				read -rp "${GREEN}Enter the value for \"$1\":${RESET} " value

				# Append key-value pair to .env
				echo "$1=$value" >> "$envfile"
				info_text "Value for key \"$1\" appended successfully!"
			fi
		fi
	else
		if [ -n "$2" ]; then
			# Create .env file and add the key-value pair
			echo "$1=$2" > "$envfile"
			info_text ".env file created successfully!"
			info_text "Value for key \"$1\" appended successfully!"
		else
			# Prompt user to enter the value
			read -rp "${GREEN}Enter the value for \"$1\":${RESET} " value

			# Create .env file and add the key-value pair
			echo "$1=$value" > "$envfile"
			info_text ".env file created successfully!"
			info_text "Value for key \"$1\" appended successfully!"
		fi
	fi
	echo ""
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
			echo -e "MIT License\n\nCopyright (c) ${user["name"]} $year\n\nPermission is hereby granted, free of charge, to any person obtaining a copy\nof this software and associated documentation files (the \"Software\"), to deal\nin the Software without restriction, including without limitation the rights\nto use, copy, modify, merge, publish, distribute, sublicense, and/or sell\ncopies of the Software, and to permit persons to whom the Software is\nfurnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all\ncopies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\nIMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\nFITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\nAUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\nLIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\nOUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE\nSOFTWARE." >> "LICENSE.md"
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

webtext() {
	lynx -dump -cookies "$1"
}

command_info() {
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
	echo "- ginit <newdir?>		${ORANGE}: setup git repo in existing/new directory${RESET}"
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
	h1_text "ENV/KEYSTORE:"
	echo "- keystore <key> <value?>	${ORANGE}: add a key-value pair to your keystore${RESET}"
	echo "- setup openai_key		${ORANGE}: setup your OpenAI API key${RESET}"
	echo "- setup smart_commit		${ORANGE}: setup your smart commit${RESET}"
	echo ""
	h1_text "FILE UTILITIES:"
	echo "- fopen				${ORANGE}: open current directory in files application${RESET}"
	echo "- find \"<regex?>\"		${ORANGE}: find a file inside the current directory using regex${RESET}"
	echo "- regex \"<regex?>\" \"<fname?>\"	${ORANGE}: return the number of regex matches in the given file${RESET}"
	echo "- rgxmatch \"<regex?>\" \"<fname?>\"${ORANGE}: return the string matches of your regex in the given file${RESET}"
	echo "- encrypt <dirname|fname?>	${ORANGE}: GPG encrypt a file/directory (saves as a new .gpg file)${RESET}"
	echo "- decrypt <fname?>	${ORANGE}: GPG decrypt a file (must be a .gpg file)${RESET}"
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
	echo "- genpass <pass-length?>	${ORANGE}: generate and copy random password string (of default length 16)${RESET}"
	echo "- genhex <hex-length?>		${ORANGE}: generate and copy random hex string (of default length 32)${RESET}"
	echo "- genb64 <base64-length?>	${ORANGE}: generate and copy random base64 string (of default length 32)${RESET}"
	echo "- copy <string?|cmd?> 		${ORANGE}: copy a string or the output of a shell command (using \$(<cmd>) syntax) to your clipboard${RESET}"
	echo "- lastcmd			${ORANGE}: copy the last command you ran to your clipboard${RESET}"
	echo ""
	h1_text "WEB UTILITIES:"
	echo "- webtext <url?>		${ORANGE}: extract readable text from a website" 
	echo ""
	h1_text	"MISC UTILITIES:"
	echo "- weather <city?>		${ORANGE}: get the weather forecast for your current location${RESET}"
	echo "- moon				${ORANGE}: get the current moon phase${RESET}"
	echo "- leap-year			${ORANGE}: tells you the next leap year"
	echo ""
	h1_text "HELP UTILITIES:"
	echo "- explain \"<cmd?>\"		${ORANGE}: explain the syntax of the input bash command${RESET}"
	echo "- ask-gpt			${ORANGE}: start a conversation with OpenAI's ChatGPT in the terminal${RESET}"
	echo "- google \"<query?>\"		${ORANGE}: google a query${RESET}"
	echo ""
}


declare -a ids
declare -A paths names publics args
# DEFAULT

if [ $num_args -eq 0 ]; then
	command_info

# GENERAL

else
	#!/bin/bash
	OLDIFS=$IFS
	IFS=","
	while read -r id path name public args
	do
		ifs+=$("$id")
	done < $1
	IFS=$OLDIFS
fi

if [ "1" = ")" ]; then
	echo "1"

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

elif [ "$1" = "genpass" ]; then
	pass_size=16
	if arggt "1"; then
		if ! [[ "$2" =~ ^[0-9]+$ ]]; then
        	error_text "Error: the password-length argument must be an integer"
			return 1
		else
			pass_size=$2
		fi
	fi
	pass=$(python3 "${scriptdir}/random_string_gen.py" "$pass_size")
	info_text "Your random password string is: ${RESET}$pass"
	clipboard "$pass"

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
	info_text "Your random hex string is: ${RESET}$truncated_pass"
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
	info_text "Your random base64 string is: ${RESET}$truncated_pass"
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

# ERROR

else
	error_text "Invalid command! Try again"
	echo "Type 'wix' to see the list of available commands (and their arguments), or 'wix help' to be redirected to more in-depth online documentation"
fi
