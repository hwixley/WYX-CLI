#!/bin/bash
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
RESET=$(tput setaf 7)

num_args="$#"
mypath=~/Documents/random-coding-projects/bashing/wix-cli.sh

declare -A mydirs
mydirs["docs"]=~/Documents
mydirs["bashing"]=~/Documents/random-coding-projects/bashing
mydirs["gs"]=~/Documents/GetSkooled
mydirs["gs-website"]=${mydirs["gs"]}/website/GetSkooled-MVP-Website
mydirs["down"]=~/Downloads
mydirs["pix"]=~/Pictures
mydirs["rcp"]=~/Documents/random-coding-projects


if [ $num_args -lt 1 ]; then
	echo "Welcome to the..."
	echo ""
	echo -e "${GREEN} ██╗    ██╗██╗██╗  ██╗     ██████╗██╗     ██╗ "
	echo -e "${GREEN} ██║    ██║██║╚██╗██╔╝    ██╔════╝██║     ██║ "
	echo -e "${GREEN} ██║ █╗ ██║██║ ╚███╔╝     ██║     ██║     ██║ "
	echo -e "${GREEN} ██║███╗██║██║ ██╔██╗     ██║     ██║     ██║ "
	echo -e "${GREEN} ╚███╔███╔╝██║██╔╝ ██╗    ╚██████╗███████╗██║ "
	echo -e "${GREEN}  ╚══╝╚══╝ ╚═╝╚═╝  ╚═╝     ╚═════╝╚══════╝╚═╝ "
	echo ""
	echo "COMMANDS:${RESET}"
	echo "- dir <cdir> : navigation"
	echo "- back : return to last dir"
	echo "- new <cdir> : new directory"
	echo "- run <cdir> : setup and run environment"
	echo "- delete <cdir> : delete dir"
	echo ""
	echo "${GREEN}GITHUB AUTOMATION:${RESET}"
	echo "- push"
	echo "- git-init"
	echo "- new-git <cdir>"
	echo "- repo"
	echo ""
	echo "${GREEN}CLI management:${RESET}"
	echo "- edit"
	echo "- save"
	echo "- cat"
	echo "- cdir"

elif [ "$1" = "dir" ]; then
	if [ $num_args -gt 1 ]; then
		if [ -v mydirs[$2] ]; then
			echo "${GREEN}Travelling to -> ${mydirs[$2]}"
			cd ${mydirs[$2]}
		else
			echo "${GREEN}That path is not supported try: docs, bashing, gs, gs-website, down"
		fi
	else
		echo "${GREEN}Where do you want to go?${RESET}"
		read dir
		if [ -v mydirs[$dir] ]; then
			echo "${GREEN}Travelling to -> ${mydirs[$dir]}"
			cd ${mydirs[$dir]}
		else
			echo "${GREEN}That path is not supported try: docs, bashing, gs, gs-website, down"
		fi
	fi
elif [ "$1" = "new" ]; then
	if [ "$2" = "gs" ]; then
		echo "${GREEN}Generating new GetSkooled dir ($gs_path/$3)..."
		mkdir $gs_path/$3
		cd $gs_path/$3
	else
		echo "${GREEN}This is only supported for gs currently"
	fi
	
elif [ "$1" = "run" ]; then
	if [ "$2" = "gs" ]; then
		echo "${GREEN}Running GetSkooled localhost server on develop"
		cd $gs_path/website/GetSkooled-MVP-Website
		git checkout develop
		git pull origin develop
		php -S localhost:8081
	else
		echo "${GREEN}This is only supported for gs currently"
	fi
	
elif [ "$1" = "delete" ]; then
	if [ "$2" = "gs" ]; then
		echo "${RED}Are you sure you want to delete $gs_path/$3? [ Yy / Nn]${RESET}"
		read response
		if [ $response = "y" ] || [ $response = "Y" ]
		then
			echo "${RED}Are you really sure you want to delete $gs_path/$3? [ Yy / Nn]${RESET}"
			read response
			if [ $response = "y" ] || [ $response = "Y" ]
			then
				echo "${RED}Deleting $gs_path/$3"
				rm -rf $gs_path/$3
			fi
		fi
	else
		echo "This is only supported for gs currently"
	fi
	
	
elif [ "$1" = "edit" ]; then
	echo "${GREEN}Edit wix-cli script..."
	gedit $my_path/wix-cli.sh
	echo "Saving changes"
	source ~/.bashrc
	
elif [ "$1" = "save" ]; then
	echo "${GREEN}Sourcing bash :)"
	source ~/.bashrc
	
elif [ "$1" = "cat" ]; then
	cat $my_path/wix-cli.sh

elif [ "$1" = "cdir" ]; then
	echo "${GREEN}Enter an alias for your new directory:${RESET}"
	read alias
	echo "${GREEN}Enter the directory:${RESET}"
	read i_dir
	echo "${GREEN}Adding $alias=$i_dir to custom dirs"
	sed -i "15imydirs["$alias"]=$i_dir" $mypath
	wix save
	

elif [ "$1" = "new-git" ]; then
	if [ "$2" = "gs" ]; then
		echo "${GREEN}Generating new GetSkooled dir ($gs_path/$3)..."
		mkdir $gs_path/$3
		cd $gs_path/$3
		echo "# $3" >> README.md
		git init
		git add .
		git commit -m "first commit"
		git remote add origin git@github.com:getskooled/$3.git
		xdg-open https://github.com/organizations/getskooled/repositories/new
	else
		echo "${GREEN}This is only supported for gs currently"
	fi
	
elif [ "$1" = "git-init" ]; then
	if [ $num_args -gt 1 ]; then
		git init
		git add .
		git commit -m "first commit"
		git remote add origin git@github.com:hwixley/$2.git
		xdg-open https://github.com/new
	else
		echo "${GREEN}Provide a repo name:${RESET}"
		read name
		git init
		git add .
		git commit -m "first commit"
		git remote add origin git@github.com:hwixley/$name.git
		xdg-open https://github.com/new
	fi
	
elif [ "$1" = "push" ]; then
	if [ $num_args -gt 1 ]; then
		git add .
		git commit -m "wix-cli quick commit"
		git push origin $2
	else
		echo "${GREEN}Provide a branch name:${RESET}"
		read name
		if [ "$name" = "" ]; then
			git add .
			git commit -m "wix-cli quick commit"
			git push origin master
		else
			git add .
			git commit -m "wix-cli quick commit"
			git push origin $name
		fi
	fi
elif [ "$1" = "repo" ]; then
	echo "${GREEN}Redirecting to repo..."
	remote=$(git config --get remote.origin.url | sed 's/.*\/\([^ ]*\/[^.]*\).*/\1/')
	repo_url=${remote#"git@github.com:"}
	repo_url=${repo_url%".git"}
	xdg-open "https://github.com/$repo_url"
	
elif [ "$1" = "branch" ]; then
	if [ $num_args -gt 1 ]; then
		git checkout -b $2
		git add .
		git commit -m "wix-cli quick commit"
		git push origin $2
	else
		echo "${GREEN}Provide a branch name:${RESET}"
		read name
		if [ "$name" != "" ]; then
			git checkout -b $name
			git add .
			git commit -m "wix-cli quick commit"
			git push origin $name
		fi
	fi
	
elif [ "$1" = "pr" ]; then
	branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
	remote=$(git config --get remote.origin.url | sed 's/.*\/\([^ ]*\/[^.]*\).*/\1/')
	repo_url=${remote#"git@github.com:"}
	repo_url=${repo_url%".git"}
	echo "${GREEN}Creating PR for $branch in $repo_url..."
	xdg-open "https://github.com/$repo_url/pull/new/$branch"
	
elif [ "$1" = "branch-pr" ]; then
	if [ $num_args -gt 1 ]; then
		git checkout -b $2
		git add .
		git commit -m "wix-cli quick commit"
		git push origin $2
		branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
		remote=$(git config --get remote.origin.url | sed 's/.*\/\([^ ]*\/[^.]*\).*/\1/')
		repo_url=${remote#"git@github.com:"}
		repo_url=${repo_url%".git"}
		echo "${GREEN}Creating PR for $branch in $repo_url..."
		xdg-open "https://github.com/$repo_url/pull/new/$branch"
	else
		echo "${GREEN}Provide a branch name:${RESET}"
		read name
		if [ "$name" != "" ]; then
			git checkout -b $name
			git add .
			git commit -m "wix-cli quick commit"
			git push origin $name
			branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
			remote=$(git config --get remote.origin.url | sed 's/.*\/\([^ ]*\/[^.]*\).*/\1/')
			repo_url=${remote#"git@github.com:"}
			repo_url=${repo_url%".git"}
			echo "${GREEN}Creating PR for $branch in $repo_url..."
			xdg-open "https://github.com/$repo_url/pull/new/$branch"
		fi
	fi
else
	echo "${RED}Invalid command! Try again"
fi
