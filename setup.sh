#!/bin/bash

mydir=$(dirname "$mypath")
source "$mydir/functions.sh"

# COLORS
GREEN=$(tput setaf 2)
ORANGE=$(tput setaf 3)
RED=$(tput setaf 1)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
BLACK=$(tput setaf 0)
RESET=$(tput setaf 7)

# FUNCTIONS
info_text() {
	echo "${GREEN}$1${RESET}"
}

h1_text() {
	echo "${BLUE}$1${RESET}"
}

warn_text() {
	echo "${ORANGE}$1${RESET}"
}

# INITIAL SETUP
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

info_text "Setting up wix-cli..."
chmod +x wix-cli.sh


# SETUP METADATA FILES
md_dir=.wix-cli-data
mkdir $md_dir
declare -a files=("git-user.txt" "git-orgs.txt" "dir-aliases.txt" "run-configs.txt" "todo.txt" ".env")
for i in "${files[@]}"; do
	touch "$md_dir/$i"
	chmod +rwx "$md_dir/$i"
done
mkdir $md_dir/run-configs


# GET USER SPECIFIC DETAILS
echo ""
h1_text "Please enter your github username:"
read -r gituser
echo "username=$gituser" >> $md_dir/git-user.txt

echo ""
h1_text "Please enter your full name (this will be used for copyright clauses on GitHub software licenses):"
read -r fullname
echo "name=$fullname" >> $md_dir/git-user.txt

echo ""
h1_text "Please enter the default github organization you want to setup with this cli: (enter it's github username) ***leave empty if none***"
read -r gitorg
if [ "$gitorg" != "" ]; then
	echo "default=$gitorg" >> $md_dir/git-orgs.txt
fi

echo ""
echo "The default directory aliases setup are as follows:"
echo "1) docs = ~/Documents"
echo "2) down = ~/Downloads"
h1_text "Would you like to include these? [ y / n ]"
read -r keep_default_diraliases
if [ "$keep_default_diraliases" = "y" ]; then
	{ echo "docs=~/Documents"; echo "down=~/Downloads"; } >> $md_dir/dir-aliases.txt
fi

# FINAL SETUP
echo ""
info_text "Okay we should be good to go!"

envfile=$(envfile)
{ echo ""; echo "# WIX CLI"; echo "alias wix=\"source $(pwd)/wix-cli.sh\""; } >> "$envfile"
source "$envfile"

echo ""
info_text "WIX CLI successfully added to $envfile !"
info_text "Use 'wix' to get going :)"
echo ""