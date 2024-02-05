#!/bin/bash

if [[ "$OSTYPE" == "darwin"* ]] || [[ "$(ps -o args= -p $$)" = *"zsh"* ]]; then
	mypath="${(%):-%N}"
else
	mypath="${BASH_SOURCE[0]}"
fi
WYX_DIR=$(dirname "$mypath")

source ${WYX_DIR}/src/classes/sys/sys.h
sys sys

setup_alias() {
	envfile=$(sys.shell.envfile)
	{ echo ""; echo "# WYX CLI"; echo "alias wyx=\"source $(pwd)/wyx-cli.sh\""; } >> "$envfile"
	source "$envfile"
}

setup_completion() {
	{ echo ""; echo "# WYX CLI"; echo "source $(pwd)/completion.sh"; } >> "$HOME/.bash_completion"
	source "$HOME/.bash_completion"
}

# Install dependencies
sys.dependencies.install

sys.log.info "Setting up wyx-cli..."
chmod +x wyx-cli.sh


# SETUP METADATA FILES
md_dir=.wyx-cli-data
if ! [ -d "$md_dir" ]; then
	mkdir $md_dir
fi
declare -a files=("git-user.txt" "git-orgs.txt" "dir-aliases.txt" "run-configs.txt" "todo.txt" ".env")
for i in "${files[@]}"; do
	if ! [ -f "$md_dir/$i" ]; then
		touch "$md_dir/$i"
		chmod +rwx "$md_dir/$i"
	else
	sys.log.warn "File $i already exists. Would you like to overwrite it? [ y / n ]"
		read -r overwrite_file
		if [ "$overwrite_file" = "y" ]; then
			rm "$md_dir/$i"
			touch "$md_dir/$i"
			chmod +rwx "$md_dir/$i"

			echo ""
			if [ "$i" = "git-user.txt" ]; then
	sys.log.h1 "Please enter your github username:"
				read -r gituser
				echo ""
	sys.log.h1 "Please enter your full name (this will be used for copyright clauses on GitHub software licenses):"
				read -r fullname
				{ echo "username=$gituser"; echo "name=$fullname"; } >> "$md_dir/$i"
			elif [ "$i" = "git-orgs.txt" ]; then
	sys.log.h1 "Please enter the default github organization you want to setup with this cli: (enter it's github username) ***leave empty if none***"
				read -r gitorg
				{ echo "default=$gitorg"; } >> "$md_dir/$i"
			elif [ "$i" = "dir-aliases.txt" ]; then
	sys.log.h1 "Would you like to include the default directory aliases? [ y / n ]"
				read -r keep_default_diraliases
				if [ "$keep_default_diraliases" = "y" ]; then
					{ echo "docs=~/Documents"; echo "down=~/Downloads"; } >> "$md_dir/$i"
				fi
			elif [ "$i" = "run-configs.txt" ]; then
	sys.log.info "Run configs flushed"
			elif [ "$i" = ".env" ]; then
	sys.log.info "Environment variables flushed"
			elif [ "$i" = "todo.txt" ]; then
	sys.log.info "TODO flushed"
				{ echo "TODO:"; echo ""; } >> "$md_dir/$i"
			fi

	sys.log.info "$i setup complete!"
		fi
		echo ""
	fi
done
if ! [ -d "$md_dir/run-configs" ]; then
	mkdir "$md_dir/run-configs"
fi


# GET USER SPECIFIC DETAILS
user_file=$(cat $md_dir/git-user.txt)
if [ "$user_file" = "" ]; then
	echo ""
	sys.log.h1 "Please enter your github username:"
	read -r gituser
	echo "username=$gituser" >> $md_dir/git-user.txt

	echo ""
	sys.log.h1 "Please enter your full name (this will be used for copyright clauses on GitHub software licenses):"
	read -r fullname
	echo "name=$fullname" >> $md_dir/git-user.txt
fi

org_file=$(cat $md_dir/git-orgs.txt)
if [ "$org_file" = "" ]; then
	echo ""
	sys.log.h1 "Please enter the default github organization you want to setup with this cli: (enter it's github username) ***leave empty if none***"
	read -r gitorg
	if [ "$gitorg" != "" ]; then
		echo "default=$gitorg" >> $md_dir/git-orgs.txt
	fi
fi

dir_file=$(cat $md_dir/dir-aliases.txt)
if [ "$dir_file" = "" ]; then
	echo ""
	echo "The default directory aliases setup are as follows:"
	echo "1) docs = ~/Documents"
	echo "2) down = ~/Downloads"
	sys.log.h1 "Would you like to include these? [ y / n ]"
	read -r keep_default_diraliases
	if [ "$keep_default_diraliases" = "y" ]; then
		{ echo "docs=~/Documents"; echo "down=~/Downloads"; } >> $md_dir/dir-aliases.txt
	fi
fi

# FINAL SETUP
echo ""
sys.log.info "Okay we should be good to go!"

# ADD ALIAS TO ENV FILE
envfile=$(sys.shell.envfile)
wyx_alias=$(cat "$envfile" | grep -c "alias wyx")
if [ "$wyx_alias" != "" ]; then
	sys.log.warn "It looks like you already have a wyx alias setup. Would you like to overwrite it? [ y / n ]"
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
	sys.log.warn "It looks like you already have wyx completion setup. Would you like to overwrite it? [ y / n ]"
		read -r overwrite_completion
		if [ "$overwrite_completion" = "y" ]; then
			echo "${ORANGE}Please edit the $HOME/.bashrc file manually to remove your old completion${RESET}"
			setup_completion
		fi
	else
		setup_completion
	fi
else
	sys.log.warn "It looks like you don't have a $HOME/.bash_completion file (allowing you to use the wyx command with tab-completion)."
	sys.log.warn "Would you like to create one? [ y / n ]"
	read -r create_completion
	if [ "$create_completion" = "y" ]; then
		touch "$HOME/.bash_completion"
		setup_completion
	else
	sys.log.error "You need to have a $HOME/.bash_completion file to use wyx completion, rerun this setup script if you would like to create one."
	fi
fi

echo ""
sys.log.info "WYX CLI setup complete !"
sys.log.info "Use 'wyx' to get going :)"
echo ""