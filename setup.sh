#!/bin/bash

# COLORS
GREEN=$(tput setaf 2)
ORANGE=$(tput setaf 3)
RED=$(tput setaf 1)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
BLACK=$(tput setaf 0)
RESET=$(tput setaf 7)

# FUNCTIONS
function info_text() {
	echo "${GREEN}$1${RESET}"
}

function h1_text() {
	echo "${BLUE}$1${RESET}"
}

function warn_text() {
	echo "${ORANGE}$1${RESET}"
}

info_text "Setting up wix-cli..."

chmod +x wix-cli-template.sh


# SETUP ENVFILE

envfile=~/.bashrc

if [ "$(uname)" == "Darwin" ]; then
	envfile=~/.zshrc
fi

while ! [ -f "$envfile" ]; do
	echo ""
	info_text "Please enter the path of your shell file:"
	read -r shellpath
	envfile=$shellpath

	if ! [ -f "$envfile" ]; then
		warn_text "Error: that file does not exist, please try again"
	fi
done


# SETUP METADATA FILES
md_dir=.wix-cli-data
mkdir $md_dir
declare -a files=("git-user" "git-orgs" "dir-aliases" "run-configs")
for i in "${files[@]}"; do
	touch $md_dir/$i.txt
	chmod +rwx $md_dir/$i.txt
done
mkdir $md_dir/run-configs


# GET USER SPECIFIC DETAILS
echo ""
h1_text "Please enter your github username:"
read gituser
echo "name=$gituser" >> $md_dir/git-user.txt

echo ""
h1_text "Please enter the default github organization you want to setup with this cli: (enter it's github username) ***leave empty if none***"
read gitorg
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
	echo "docs=~/Documents" >> $md_dir/dir-aliases.txt
	echo "down=~/Downloads" >> $md_dir/dir-aliases.txt
fi

# FINAL SETUP
echo ""
info_text "Okay we should be good to go!"

echo "" >> "$envfile"
echo "# WIX CLI" >> "$envfile"
echo "alias wix=\"source $(pwd)/wix-cli.sh\"" >> "$envfile"
source "$envfile"

echo ""
info_text "WIX CLI successfully added to $envfile !"
info_text "Use 'wix' to get going :)"
echo ""