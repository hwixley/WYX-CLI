#!/bin/bash

chmod +x wix-cli-template.sh

envfile=~/.bashrc

if [ "$(uname)" == "Darwin" ]; then
	envfile=~/.zshrc
fi

if [ -d "$envfile" ]; then
	echo ""
	echo "Please enter the path of your shell file:"
	read -r shellpath
	envfile=$shellpath
else
	echo ""
	echo "Is $envfile the correct directory to be appending to? [ y / n]"
	read response

	if [ "$response" != "y" ]; then
		echo ""
		echo "Please enter the path of your shell file:"
		read -r shellpath
		envfile=$shellpath
	fi
fi

echo "" >> "$envfile"
echo "# WIX CLI" >> "$envfile"
echo "alias wix=\"source $(pwd)/wix-cli-template.sh\"" >> "$envfile"
source "$envfile"

GREEN=$(tput setaf 2)
echo ""
echo "${GREEN}WIX CLI successfully added to $envfile !"
echo ""
echo "Use 'wix' to get going :)"