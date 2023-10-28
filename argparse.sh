#!/bin/bash

# CLI CONSTS
version="1.1.0"
num_args=$#
mypath=$(readlink -f "${BASH_SOURCE:-$0}")
date=$(date)
year="${date:24:29}"

mydir=$(dirname "${mypath}")
datadir="${mydir}/.wix-cli-data"
scriptdir="${mydir}/scripts"

# shellcheck source-path=SCRIPTDIR
# shellcheck source=functions.sh
. "${mydir}/functions.sh"
. "${mydir}/services.sh"

# DEFAULT

if [[ $num_args -eq 0 ]]; then
	command_info

# GENERAL

elif [[ "$1" = "sys-info" ]]; then
	if using_zsh; then
		echo "ZSH (0_0)"
	else
		echo "BASH (-_-)"
	fi

elif [[ "$1" = "cd" ]]; then
	wix_cd "$2"
	
elif [[ "$1" = "back" ]]; then
	cd - || error_text "Failed to execute 'cd -'..."
	
elif [[ "$1" = "new" ]]; then
	wix_new "$2" "$3"
	
elif [[ "$1" = "run" ]]; then
	wix_run "$2"
	
elif [[ "$1" = "vsc" ]]; then
	if direxists "$2"; then
		wix_cd "$2"
		info_text "Opening up VSCode editor..."
		code .
	else
		error_text "Error: this directory alias does not exist, please try again"
	fi

elif [[ "$1" = "delete" ]]; then
	wix_delete "$2" "$3"

elif [[ "$1" = "hide" ]]; then
	echo "not implemented yet"

elif [[ "$1" = "genpass" ]]; then
	pass_size=16
	if arggt "1"; then
		if ! [[ "$2" =~ ^[0-9]+$ ]]; then
        	error_text "Error: the password-length argument must be an integer"
			return 1
		else
			pass_size=$2
		fi
	fi
	pass=$(python3 "${scriptdir}/random_string_gen.py" "${pass_size}")
	info_text "Your random password string is: ${RESET}$pass"
	clipboard "${pass}"

elif [[ "$1" = "genhex" ]]; then
	hex_size=32
	if arggt "1"; then
		if ! [[ "$2" =~ ^[0-9]+$ ]]; then
        	error_text "Error: the hex-length argument must be an integer"
			return 1
		else
			hex_size=$2
		fi
	fi
	pass=$(openssl rand -hex "${hex_size}")
	truncated_pass="${pass}:0:${hex_size}"
	info_text "Your random hex string is: ${RESET}${truncated_pass}"
	clipboard "${truncated_pass}"

elif [[ "$1" = "genb64" ]]; then
	hex_size=32
	if arggt "1"; then
		if ! [[ "$2" =~ ^[0-9]+$ ]]; then
        	error_text "Error: the base64-length argument must be an integer"
			return 1
		else
			hex_size=$2
		fi
	fi
	pass=$(openssl rand -base64 "${hex_size}")
	truncated_pass="${pass:0:$hex_size}"
	info_text "Your random base64 string is: ${RESET}$truncated_pass"
	clipboard "${truncated_pass}"

# CLI MANAGEMENT

elif [[ "$1" = "edit" ]]; then
	warn_text "Edit wix-cli script..."
	editfile "${mypath}"
	info_text "Saving changes to $mypath..."
	source $(envfile)
	
elif [[ "$1" = "save" ]]; then
	info_text "Sourcing bash :)"
	source $(envfile)
	
elif [[ "$1" = "cat" ]]; then
	cat "${mypath}"

elif [[ "$1" = "-v" ]] || [[ "$1" = "--version" ]] || [[ "$1" = "version" ]]; then
	echo "v$version"

# elif [[ "$1" = "cdir" ]]; then
# 	info_text "Enter an alias for your new directory:"
# 	read -r alias
# 	info_text "Enter the directory:"
# 	read -r i_dir
# 	info_text "Adding $alias=$i_dir to custom dirs"
# 	sed -i "${insertline}imydirs["${alias}"]=$i_dir" $mypath
# 	wix save
	
# elif [[ "$1" = "mydirs" ]]; then
# 	for x in $dirkeys; do printf "[%s]=%s\n" "${x}" "${mydirs[$x]}" ; done
	

# GITHUB AUTOMATION

# elif [[ "$1" = "gnew" ]]; then
# 	wix_gnew "$2" "$3"
	
elif [[ "$1" = "ginit" ]]; then
	wix_ginit "$2"
	
elif [[ "$1" = "push" ]]; then
	if arggt "1" ; then
		push "$2"
	else
		push "${branch}"
	fi

elif [[ "$1" = "pull" ]]; then
	if arggt "1" ; then
		pull "$2"
	else
		pull "${branch}"
	fi

elif [[ "$1" = "mpull" ]]; then
	if [[ "$(git branch --list master)" ]]; then
		pull "master"
	elif [[ "$(git branch --list main)" ]]; then
		pull "main"
	else
		warn_text "No master or main branch found..."
	fi

elif [[ "$1" = "repo" ]]; then
	info_text "Redirecting to $repo_url..."
	giturl "https://github.com/$repo_url"

elif [[ "$1" = "branch" ]]; then
	info_text "Redirecting to $branch on $repo_url..."
	giturl "https://github.com/$repo_url/tree/$branch"

elif [[ "$1" = "actions" ]]; then
	info_text "Redirecting to Action Workflows on $repo_url..."
	giturl "https://github.com/$repo_url/actions"

elif [[ "$1" = "issues" ]]; then
	info_text "Redirecting to Issues on $repo_url..."
	giturl "https://github.com/$repo_url/issues"

elif [[ "$1" = "prs" ]]; then
	info_text "Redirecting to Pull Requests on $repo_url..."
	giturl "https://github.com/$repo_url/pulls"

elif [[ "$1" = "notifs" ]]; then
	info_text "Redirecting to your Notifications..."
	giturl "https://github.com/notifications"

elif [[ "$1" = "commits" ]]; then
	git log --pretty=format:"${GREEN}%H${RESET} - ${BLUE}%an${RESET}, ${ORANGE}%cr [%cd]${RESET} : %s"

elif [[ "$1" = "lastcommit" ]]; then
	clipboard "$(git rev-parse HEAD)"
	git show HEAD

elif [[ "$1" = "nb" ]]; then
	if arggt "1" ; then
		npush "$2"
	else
		info_text "Provide a branch name:"
		read -r name
		if [[ "${name}" != "" ]]; then
			npush "${name}"
		else
			error_text "Invalid branch name"
		fi
	fi
	
elif [[ "$1" = "pr" ]]; then
	info_text "Creating PR for $branch in $repo_url..."
	giturl "https://github.com/$repo_url/pull/new/$branch"
	
elif [[ "$1" = "bpr" ]]; then
	if is_git_repo ; then
		if arggt "1" ; then
			bpr "$2"
		else
			info_text "Provide a branch name:"
			read -r name
			if [[ "${name}" != "" ]]; then
				bpr "${name}"
			fi
		fi
	fi

elif [[ "$1" = "profile" ]]; then
	openurl "https://github.com/${user[username]}"

elif [[ "$1" = "org" ]]; then
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

elif [[ "$1" = "help" ]]; then
	openurl "https://hwixley.github.io/WIX-CLI/index.html"

# MY DATA

elif [[ "$1" = "user" ]]; then
	cat "$datadir/git-user.txt"

elif [[ "$1" = "mydirs" ]]; then
	cat "$datadir/dir-aliases.txt"

elif [[ "$1" = "myorgs" ]]; then
	cat "$datadir/git-orgs.txt"

elif [[ "$1" = "myscripts" ]]; then
	cat "$datadir/run-configs.txt"

elif [[ "$1" = "todo" ]]; then
	cat "$datadir/todo.txt"

elif [[ "$1" = "editd" ]]; then
	data_to_edit="$2"
	if ! arggt "1"; then
		info_text "What data would you like to edit?"
		read -r data_to_edit_prompt
		data_to_edit=$data_to_edit_prompt

		declare -a datanames
		datanames=( "user" "myorgs" "mydirs" "myscripts" )
		if ! printf '%s\0' "${datanames[@]}" | grep -Fxqz -- "${data_to_edit_prompt}"; then
			error_text "'$data_to_edit_prompt' is not a valid piece of data, please try one of the following: ${datanames[*]}"
			return 1
		fi
	fi
	if [[ "${data_to_edit}" = "user" ]]; then
		editfile "$datadir/git-user.txt"
	elif [[ "${data_to_edit}" = "myorgs" ]]; then
		editfile "$datadir/git-orgs.txt"
	elif [[ "${data_to_edit}" = "mydirs" ]]; then
		editfile "$datadir/dir-aliases.txt"
	elif [[ "${data_to_edit}" = "myscripts" ]]; then
		editfile "$datadir/run-configs.txt"
	elif [[ "${data_to_edit}" = "todo" ]]; then
		editfile "$datadir/todo.txt"
	fi

elif [[ "$1" = "create-script" ]]; then
	script_name="$2"
	if ! arggt "1"; then
		info_text "Enter the name of the script you would like to add:"
		read -r script_name_prompt
		script_name=$script_name_prompt
	fi
	fname="$datadir/run-configs/$script_name.sh"
	touch "${fname}"
	chmod u+x "${fname}"
	editfile "${fname}"

elif [[ "$1" = "edits" ]]; then
	script_to_edit="$2"
	if ! arggt "1"; then
		info_text "What script would you like to edit?"
		read -r script_to_edit_prompt
		script_to_edit=$script_to_edit_prompt
	fi
	if scriptexists "${script_to_edit}"; then
		info_text "Editing $script_to_edit script..."
		editfile "$datadir/run-configs/$script_to_edit.sh"
	else
		error_text "This script does not exist... Please try again"
	fi

elif [[ "$1" = "newscript" ]]; then
	name="$2"
	if ! arggt "1"; then
		info_text "What would you like to call your script? (no spaces)"
		read -r name_prompt
		name="${name_prompt}"
	fi
	if [[ -f "$datadir/$name.sh" ]]; then
		error_text "Error: this script name already exists"
	else
		info_text "Creating new script..."
		echo "$name=$name" >> "$datadir/run-configs.txt"
		touch "$datadir/run-configs/$name.sh"
		editfile "$datadir/run-configs/$name.sh"
	fi

# FILE CREATION

elif [[ "$1" = "newf" ]]; then
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

elif [[ "$1" = "find" ]]; then
	if arggt "1"; then
		find . -type f -name "$2"
	else
		info_text "Enter the filename you would like to find:"
		read -r fname
		find . -type f -name "${fname}"
	fi

# CLIPBOARD

elif [[ "$1" = "copy" ]]; then
	if arggt "1"; then
		if [[ "$2" =~ ^\$\(.*\)$ ]]; then
			DATA="$2"
			clipboard "${DATA}"
		else
			clipboard "$2"
		fi
	else
		info_text "Enter the text you would like to copy to your clipboard:"
		read -r text
		clipboard "${text}"
	fi

# LAST COMMAND

elif [[ "$1" = "lastcmd" ]]; then
	lastcmd=$(fc -ln -1)
	trimmed=$(echo "${lastcmd}" | xargs)
	clipboard "${trimmed}"

# IP ADDRESS

elif [[ "$1" = "ip" ]]; then
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
	ip=$(echo "${public_ip}" | jq -r '.ip')
	city=$(echo "${public_ip}" | jq -r '.city')
	region=$(echo "${public_ip}" | jq -r '.region_name')
	zip=$(echo "${public_ip}" | jq -r '.zip_code')
	country=$(echo "${public_ip}" | jq -r '.country')
	lat=$(echo "${public_ip}" | jq -r '.latitude')
	long=$(echo "${public_ip}" | jq -r '.longitude')
	time_zone=$(echo "${public_ip}" | jq -r '.time_zone')
	asn_org=$(echo "${public_ip}" | jq -r '.asn_org')
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

elif [[ "$1" = "wifi" ]]; then
	if mac; then
		/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport scan
	else
		python3 "${scriptdir}/wifi_sniffer.py"
	fi

elif [[ "$1" = "hardware-ports" ]]; then
	if mac; then
		networksetup -listallhardwareports
	else
		echo "Not supported on this OS"
	fi

elif [[ "$1" = "wpass" ]]; then
	if mac; then
		info_text "Enter the SSID of the network you would like to get the password for:"
		read -r ssid
		info_text "Getting password for $ssid..."
		security find-generic-password -ga "${ssid}" | grep "password:"
		echo ""
	else
		info_text "Listing saved Wifi passwords:"
		sudo grep -r '^psk=' /etc/NetworkManager/system-connections/
	fi

elif [[ "$1" = "speedtest" ]]; then
	info_text "Running speedtest..."
	speedtest

# QR CODE

elif [[ "$1" = "genqr" ]]; then
	link="$2"
	fname="$3"
	if ! arggt "1"; then
		info_text "Enter the URL you would like to link to:"
		read -r url
		link="${url}"

		if ! arggt "2"; then
			info_text "Enter the name for your QR code:"
			read -r qrname
			fname="${qrname}"
		fi
	fi
	info_text "Generating a QR code..."
	qrencode -o "$fname.png" "${link}"
	display "$fname.png"

# UPSCALE PHOTO

elif [[ "$1" = "upscale" ]]; then
	fname="$2"
	alpha="$3"
	if ! arggt "1"; then
		info_text "Enter the file you would like to upscale:"
		read -r url
		fname="${url}"

		if ! arggt "2"; then
			info_text "Enter the scale multiplier:"
			read -r mult
			alpha="${mult}"
		fi
	fi
	info_text "Upscaling $fname..."
	python3 "$scriptdir/photo-upscale.py" "${fname}" "${alpha}"

# OPEN FILE

elif [[ "$1" = "fopen" ]]; then
	if arggt "1"; then
		dir="$2"
		if direxists "${dir}"; then
			mydir="${mydirs[$dir]/\~/${HOME}}"
			info_text "Opening $mydir..."
			openfile "${mydir}"
		else
			error_text "Directory alias does not exist"
		fi
	else
		info_text "Opening current directory..."
		openfile "$(pwd)"
	fi

# REGEX SEARCH

elif [[ "$1" = "regex" ]]; then
	if arggt "1"; then
		regex="$2"
		if arggt "2"; then
			fname="$3"
			if [[ -f "${fname}" ]]; then
				info_text "Searching for $regex in $fname..."
				info_text "Number of matches:"
				grep -c "${regex}" "${fname}"
			else
				error_text "File does not exist"
			fi
		else
			info_text "Enter the filename you would like to search:"
			read -r fname
			if [[ -f "${fname}" ]]; then
				info_text "Searching for $regex in $fname..."
				info_text "Number of matches:"
				grep -c "${regex}" "${fname}"
			else
				error_text "File does not exist"
			fi
		fi
	else
		info_text "Enter the regex you would like to search for:"
		read -r regex
		info_text "Enter the filename you would like to search:"
		read -r fname
		if [[ -f "${fname}" ]]; then
			info_text "Searching for $regex in $fname..."
			grep -E "${regex}" "${fname}"
		else
			error_text "File does not exist"
		fi
	fi

elif [[ "$1" = "rgxmatch" ]]; then
	if arggt "1"; then
		regex="$2"
		if arggt "2"; then
			fname="$3"
			if [[ -f "${fname}" ]]; then
				info_text "Searching for $regex in $fname..."
				echo ""
				info_text "Matches: "
				data=$(cat "${fname}")
				[[ "${data}" =~ $regex ]]
				token=$(echo "${BASH_REMATCH[1]}")
				echo "${token}"
				clipboard "${token}"
			else
				error_text "File does not exist"
			fi
		else
			info_text "Enter the filename you would like to search:"
			read -r fname
			if [[ -f "${fname}" ]]; then
				info_text "Searching for $regex in $fname..."
				echo ""
				info_text "Matches: "
				data=$(cat "${fname}")
				[[ "${data}" =~ $regex ]]
				token=$(echo "${BASH_REMATCH[1]}")
				echo "${token}"
				clipboard "${token}"
			else
				error_text "File does not exist"
			fi
		fi
	else
		info_text "Enter the regex you would like to search for:"
		read -r regex
		info_text "Enter the filename you would like to search:"
		read -r fname
		if [[ -f "${fname}" ]]; then
			info_text "Searching for $regex in $fname..."
			grep -c "${regex}" "${fname}"
		else
			error_text "File does not exist"
		fi
	fi

# ENCRYPTION

elif [[ "$1" = "encrypt" ]]; then
	info_text "Encrypting $2..."
	if arggt "1"; then
		if [[ -d "$2" ]]; then
			tar -cvf "$2.tar" "$2"
			gpg -c "$2.tar"
			rm "$2.tar"
			info_text "$2.tar.gpg file created successfully!"
		
		elif [[ -f "$2" ]]; then
			gpg -c "$2"
			info_text "$2.gpg file created successfully!"
		
		else
			error_text "File path provided does not exist. Please try again"
		fi
	else
		info_text "Enter the file/directory you would like to encrypt:"
		read -r filepath

		if [[ -d "${filepath}" ]]; then
			tar -cvf "$filepath.tar" "${filepath}"
			gpg -c "$filepath.tar"
			rm "$filepath.tar"
			info_text "$filepath.tar.gpg file created successfully!"
		
		elif [[ -f "${filepath}" ]]; then
			gpg -c "${filepath}"
			info_text "$filepath.gpg file created successfully!"

		else
			error_text "File path provided does not exist. Please try again"
		fi
	fi

elif [[ "$1" = "decrypt" ]]; then
	info_text "Decrypting $2..."
	if arggt "1"; then
		if [[ -f "$2" ]]; then
			gpg -d "$2"
			info_text "$2 file decrypted successfully!"
		else
			error_text "File path provided does not exist. Please try again"
		fi
	else
		info_text "Enter the file you would like to decrypt: (must have a .gpg extension)"
		read -r filepath
		if [[ -f "${filepath}" ]]; then
			gpg -d "${filepath}"
			info_text "$filepath file decrypted successfully!"
		else
			error_text "File path provided does not exist. Please try again"
		fi
	fi

# MISC UTILITIES

elif [[ "$1" = "weather" ]]; then
	if arggt "1"; then
		city="$2"
		info_text "Getting weather for $city..."
		curl wttr.in/"${city}"
	else
		info_text "Getting weather for your current location..."
		curl wttr.in
	fi

elif [[ "$1" = "moon" ]]; then
	info_text "Getting moon phase..."
	curl wttr.in/moon

elif [[ "$1" = "leap-year" ]]; then
	if [[ "${year}" =~ ^[0-9]*00$ ]]; then
		if [[ "$((year % 400))" -eq 0 ]]; then
			info_text "$year is a leap year"
		else
			info_text "$year is not a leap year"
		fi
	elif [[ "$((year % 4))" -eq 0 ]]; then
		info_text "$year is a leap year"
	else
		info_text "$year is not a leap year"
	fi
	next_one=$((year + 4 - (year % 4)))
	info_text "The next leap year is $next_one"

# WEB UTILITIES

elif [[ "$1" = "webtext" ]]; then
	if arggt "1"; then
		webtext "$2"
	else
		info_text "Enter the webpage you would like to parse:"
		read -r webpage
		webtext "${webpage}"
	fi

# HELP UTILITIES

elif [[ "$1" = "explain" ]]; then
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

elif [[ "$1" = "ask-gpt" ]]; then
	python3 "${scriptdir}/services/openai_service.py" "conversate"

elif [[ "$1" = "google" ]]; then
	if arggt "1"; then
		openurl "https://www.google.com/search?q=$2"
	else
		prompt_text "\nEnter your Google search query:"
		read -r query
		openurl "https://www.google.com/search?q=$query"
	fi
	echo ""

# UPDATE

elif [[ "$1" = "update" ]]; then
	cd "${mydir}" || error_text "Failed to execute 'cd $mydir'..." && exit
	git pull origin master
	cd - || error_text "Failed to execute 'cd -'..." && exit

elif [[ "$1" = "install-deps" ]]; then
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

elif [[ "$1" = "keystore" ]]; then
	if arggt "1"; then
		if arggt "2"; then
			check_keystore "$2" "$3"
		else
			check_keystore "$2"
		fi
	else
		read -rp "${GREEN}Enter the key you would like to add to your keystore:${RESET} " key
		check_keystore "${key}"
	fi
	info_text "You're done!"

elif [[ "$1" = "setup" ]]; then
	if [[ "$2" = "openai_key" ]]; then
		info_text "Setting up OpenAI key..."
		echo ""
		check_keystore "OPENAI_API_KEY"
		info_text "You're done!"

	elif [[ "$2" = "smart_commit" ]]; then
		info_text "Setting up smart commit..."
		echo ""
		check_keystore "OPENAI_API_KEY"
		check_keystore "USE_SMART_COMMIT" "true"
		info_text "You're done!"
		
	else
		error_text "Invalid setup command! Try again"
		echo "Type 'wix' to see the list of available commands (and their arguments), or 'wix help' to be redirected to more in-depth online documentation"
	fi

# COMMAND INFO IMAGE OUTPUT - FOR GITHUB ACTIONS WORKFLOW

elif [[ "$1" = "img_stdout" ]]; then
	output=$(command_info | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2};?)?)?[mGK]//g")
	output="\$ wix\n\n$output\n"

	convert -background "#300A24" -fill white -font "DejaVu-Sans-Mono" -pointsize 18 -border 20x15 -bordercolor "#300A24" label:"${output}" .generated/wixcli-output-preview.png

# ERROR

else
	error_text "Invalid command! Try again"
	echo "Type 'wix' to see the list of available commands (and their arguments), or 'wix help' to be redirected to more in-depth online documentation"
fi
