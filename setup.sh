#!/bin/bash

source $(dirname ${BASH_SOURCE[0]})/src/classes/sys/sys.h

setup_alias() {
	envfile=$(sys.shell.envfile)
	{ echo ""; echo "# WYX CLI"; echo "alias wyx=\"source $(pwd)/wyx-cli.sh\""; } >> "$envfile"
	source "$envfile"
}

setup_completion() {
	{ echo ""; echo "# WYX CLI"; echo "source $(pwd)/completion.sh"; } >> "$HOME/.bash_completion"
	source "$HOME/.bash_completion"
}

# INITIAL SETUP
if ! sys.shell.zsh; then
	sys.info "Installing dependencies..."
	sudo apt-get install xclip csvkit
	curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
	sudo apt-get install speedtest
fi

if sys.os.mac; then
	sys.info "Installing dependencies..."
	brew install xclip jq
	brew tap teamookla/speedtest
	brew install speedtest --force
fi

sys.info "Installing python dependencies..."
pip3 install -r requirements.txt

sys.info "Setting up wyx-cli..."
chmod +x wyx-cli.sh


# SETUP METADATA FILES
md_dir=.wyx-cli-data
mkdir $md_dir
declare -a files=("git-user.txt" "git-orgs.txt" "dir-aliases.txt" "run-configs.txt" "todo.txt" ".env")
for i in "${files[@]}"; do
	if ! [ -f "$md_dir/$i" ]; then
		touch "$md_dir/$i"
		chmod +rwx "$md_dir/$i"
	else
		sys.warn "File $i already exists. Would you like to overwrite it? [ y / n ]"
		read -r overwrite_file
		if [ "$overwrite_file" = "y" ]; then
			rm "$md_dir/$i"
			touch "$md_dir/$i"
			chmod +rwx "$md_dir/$i"
		fi
	fi
done
if ! [ -d "$md_dir/run-configs" ]; then
	mkdir "$md_dir/run-configs"
fi


# GET USER SPECIFIC DETAILS
echo ""
sys.h1 "Please enter your github username:"
read -r gituser
echo "username=$gituser" >> $md_dir/git-user.txt

echo ""
sys.h1 "Please enter your full name (this will be used for copyright clauses on GitHub software licenses):"
read -r fullname
echo "name=$fullname" >> $md_dir/git-user.txt

echo ""
sys.h1 "Please enter the default github organization you want to setup with this cli: (enter it's github username) ***leave empty if none***"
read -r gitorg
if [ "$gitorg" != "" ]; then
	echo "default=$gitorg" >> $md_dir/git-orgs.txt
fi

echo ""
echo "The default directory aliases setup are as follows:"
echo "1) docs = ~/Documents"
echo "2) down = ~/Downloads"
sys.h1 "Would you like to include these? [ y / n ]"
read -r keep_default_diraliases
if [ "$keep_default_diraliases" = "y" ]; then
	{ echo "docs=~/Documents"; echo "down=~/Downloads"; } >> $md_dir/dir-aliases.txt
fi

# FINAL SETUP
echo ""
sys.info "Okay we should be good to go!"

# ADD ALIAS TO ENV FILE
envfile=$(envfile)
if [ "$(alias wyx)" != "" ]; then
	sys.warn "It looks like you already have a wyx alias setup. Would you like to overwrite it? [ y / n ]"
	read -r overwrite_alias
    if [ "$overwrite_alias" = "y" ]; then
		echo "${ORANGE}Please edit the $envfile file manually to remove your old alias${RESET}"
        setup_alias
    fi
else
	setup_alias
fi

# ADD COMPLETION TO COMPLETION FILE
completionfile="$HOME/.bash_completion"
if [ -f "$completionfile" ]; then
	completion_search=$(cat "$completionfile" | grep -c "$(pwd)/completion.sh")
	if [ "$completion_search" != "" ]; then
		sys.warn "It looks like you already have wyx completion setup. Would you like to overwrite it? [ y / n ]"
		read -r overwrite_completion
		if [ "$overwrite_completion" = "y" ]; then
			echo "${ORANGE}Please edit the $HOME/.bashrc file manually to remove your old completion${RESET}"
			setup_completion
		fi
	else
		setup_completion
	fi
else
	sys.warn "It looks like you don't have a $HOME/.bash_completion file (allowing you to use the wyx command with tab-completion)."
	sys.warn "Would you like to create one? [ y / n ]"
	read -r create_completion
	if [ "$create_completion" = "y" ]; then
		touch "$HOME/.bash_completion"
		setup_completion
	else
		sys.error "You need to have a $HOME/.bash_completion file to use wyx completion, rerun this setup script if you would like to create one."
	fi
fi

echo ""
sys.info "WYX CLI successfully added to $envfile !"
sys.info "Use 'wyx' to get going :)"
echo ""