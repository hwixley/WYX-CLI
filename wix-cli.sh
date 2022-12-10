#!/bin/bash

echo ""
echo " ██╗    ██╗██╗██╗  ██╗     ██████╗██╗     ██╗"
echo " ██║    ██║██║╚██╗██╔╝    ██╔════╝██║     ██║"
echo " ██║ █╗ ██║██║ ╚███╔╝     ██║     ██║     ██║"
echo " ██║███╗██║██║ ██╔██╗     ██║     ██║     ██║"
echo " ╚███╔███╔╝██║██╔╝ ██╗    ╚██████╗███████╗██║"
echo "  ╚══╝╚══╝ ╚═╝╚═╝  ╚═╝     ╚═════╝╚══════╝╚═╝"
echo ""
my_path=~/Documents/random-coding-projects/bashing
gs_path=~/Documents/GetSkooled
num_args="$#"
if [ $num_args -lt 1 ]; then
	echo "                                              _" 
	echo "(   // _ _ _   _/             _  _/ _/   _     )"
	echo "|/|//)(-/ (-  (/() (/()(/ ((/(//)/  /() (/()  . "
	echo "                   /                   _/       "
	read dir
	
	
	if [ $dir = "docs" ]; then
		cd ~/Documents
	elif [ $dir = "bashing" ]; then
		cd $my_path
	elif [ $dir = "gs" ]; then
		cd $gs_path
	elif [ $dir = "gs-website" ]; then
		cd $gs_path/website/GetSkooled-MVP-Website
	elif [ $dir = "down" ]; then
		cd ~/Downloads
	fi
elif [ $num_args -gt 2 ]; then
	if [ $1 = "new" ]; then
		if [ $2 = "gs" ]; then
			echo "Generating new GetSkooled dir ($gs_path$3)..."
			mkdir $gs_path$3
			cd $gs_path$3
		fi
	elif [ $1 = "new-git" ]; then
		if [ $2 = "gs" ]; then
			echo "Generating new GetSkooled dir ($gs_path/$3)..."
			mkdir $gs_path/$3
			cd $gs_path/$3
			echo "# $3" >> README.md
			git init
			git add .
			git commit -m "first commit"
			git remote add origin git@github.com:getskooled/$3.git
			xdg-open https://github.com/organizations/getskooled/repositories/new
		fi
	elif [ $1 = "run" ]; then
		if [ $2 = "gs" ]; then
			echo "Running GetSkooled localhost server on develop"
			cd $gs_path/website/GetSkooled-MVP-Website
			git checkout develop
			git pull origin develop
			php -S localhost:8081
		fi
	elif [ $1 = "delete" ]; then
		if [ $2 = "gs" ]; then
			echo "Are you sure you want to delete $gs_path/$3? (Yy/Nn)"
			read response
			if [ $response = "y" ] || [ $response = "Y" ]
			then
				echo "Deleting $gs_path/$3"
				rm -rf $gs_path/$3
			fi
		fi
	fi
elif [ $1 = "edit" ]; then
	echo "Edit wix-cli script..."
	gedit $my_path/wix-cli.sh
	echo "Saving changes"
	source ~/.bashrc
elif [ $1 = "save" ]; then
	echo "Sourcing bash :)"
	source ~/.bashrc
elif [ $1 = "cat" ]; then
	cat $my_path/wix-cli.sh
elif [ $1 = "git-init" ]; then
	if [ $num_args -gt 1 ]; then
		git init
		git add .
		git commit -m "first commit"
		git remote add origin git@github.com:hwixley/$2.git
		xdg-open https://github.com/new
	else
		echo "Provide a repo name:"
		read name
		git init
		git add .
		git commit -m "first commit"
		git remote add origin git@github.com:hwixley/$name.git
		xdg-open https://github.com/new
	fi
elif [ $1 = "push" ]; then
	if [ $num_args -gt 1 ]; then
		git add .
		git commit -m "wix-cli quick commit"
		git push origin $2
	else
		echo "Provide a branch name:"
		read name
		if [ $name = "" ]; then
			git add .
			git commit -m "wix-cli quick commit"
			git push origin master
		else
			git add .
			git commit -m "wix-cli quick commit"
			git push origin $name
		fi
	fi
elif [ $1 = "repo" ]; then
	echo "repo"
	remote=$(git config --get remote.origin.url | sed 's/.*\/\([^ ]*\/[^.]*\).*/\1/')
	repo_url=${remote#"git@github.com:"}
	repo_url=${repo_url%".git"}
	xdg-open "https://github.com/$repo_url"
else
	echo "Invalid command! Try again"
fi
