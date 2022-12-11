#!/bin/bash
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
RESET=$(tput setaf 7)

# CLI CONSTS
num_args="$#"
mypath=~/Documents/random-coding-projects/bashing/wix-cli.sh
[ $num_args -gt 1 ] ; gt1=$?
[ $num_args -gt 2 ] ; gt2=$?
echo "hi2"

# GIT CONSTS
branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
remote=$(git config --get remote.origin.url | sed 's/.*\/\([^ ]*\/[^.]*\).*/\1/')
repo_url=${remote#"git@github.com:"}
repo_url=${repo_url%".git"}

declare -A myorgs
myorgs["gs"]="getskooled"

# DIR CONSTS
insertline=23

declare -A mydirs
mydirs["docs"]=~/Documents
mydirs["self"]=~/Documents/random-coding-projects/bashing
mydirs["gs"]=~/Documents/GetSkooled
mydirs["gs-website"]=${mydirs["gs"]}/website/GetSkooled-MVP-Website
mydirs["down"]=~/Downloads
mydirs["pix"]=~/Pictures
mydirs["rcp"]=~/Documents/random-coding-projects

diraliases=$(echo ${!mydirs[@]} | sed 's/ / - /g' )

# FILE EXTs
exts=("sh" "txt" "py")

# ECHOS
notsupported="${RED}That path is not supported try: $diraliases"


# DEFAULT

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
	echo "v0.0.0.0"
	echo ""
	echo "COMMANDS:${RESET}"
	echo "- cd <cdir> 		: navigation"
	echo "- back 			: return to last dir"
	echo "- new <cdir> 		: new directory"
	echo "- run <cdir> 		: setup and run environment"
	echo "- delete <cdir> 	: delete dir"
	echo ""
	echo "${GREEN}GITHUB AUTOMATION:${RESET}"
	echo "- push <branch?>	: push changes"
	echo "- ginit			: init git repo"
	echo "- ngit <cdir>	 	: create and init git repo"
	echo "- repo 			: go to repo url"
	echo "- branch 		: go to branch url"
	echo "- nbranch 		: create new branch"
	echo "- pr 			: create PR for branch"
	echo "- bpr 			: checkout changes and create PR for branch"
	echo ""
	echo "${GREEN}CLI management:${RESET}"
	echo "- edit"
	echo "- save"
	echo "- cat"
	echo "- cdir"
	echo "- mydirs"


# GENERAL

elif [ "$1" = "cd" ]; then
	if [ $gt1 ]; then
		if [ -v mydirs[$2] ]; then
			echo "${GREEN}Travelling to -> ${mydirs[$2]}"
			cd ${mydirs[$2]}
		else
			echo $notsupported
		fi
	else
		echo "${GREEN}Where do you want to go?${RESET}"
		read dir
		if [ -v mydirs[$dir] ]; then
			echo "${GREEN}Travelling to -> ${mydirs[$dir]}"
			cd ${mydirs[$dir]}
		else
			echo $notsupported
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
	

# CLI MANAGEMENT

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
	sed -i "${insertline}imydirs["$alias"]=$i_dir" $mypath
	wix save
	
elif [ "$1" = "mydirs" ]; then
	for x in "${!mydirs[@]}"; do printf "[%s]=%s\n" "$x" "${mydirs[$x]}" ; done
	

# GITHUB AUTOMATION

elif [ "$1" = "gnew" ]; then
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
	
elif [ "$1" = "ginit" ]; then
	echo "${GREEN}Initializing git repo..."
	git init
	git add .
	git commit -m "first commit"
	
	if [ $gt1 ]; then
		if [ -v myorgs[$2] ]; then
			if [ $gt2 ]; then
				git remote add origin "git@github.com:${myorgs[$2]}/$3.git"
			else
				echo "${GREEN}Provide a repo name:${RESET}"
				read name
				git remote add origin "git@github.com:${myorgs[$2]}/$name.git"
			fi
			xdg-open "https://github.com/organizations/${myorgs[$2]}/repositories/new"
		else
			git remote add origin "git@github.com:hwixley/$2.git"
			xdg-open "https://github.com/new"
		fi
	else
		echo "${GREEN}Provide a repo name:${RESET}"
		read name
		git remote add origin git@github.com:hwixley/$name.git
		xdg-open https://github.com/new
	fi
	
elif [ "$1" = "push" ]; then
	if [ $gt1 ]; then
		echo "${GREEN}Provide a commit description:${RESET}"
		read description
		git checkout $2
		git add .
		git commit -m "${description:-wix-cli quick commit}"
		git push origin $2
	else
		branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')	
		echo "${GREEN}Provide a commit description:${RESET}"
		read description
		if [ "$name" = "" ]; then
			git add .
			git commit -m "${description:-wix-cli quick commit}"
			git push origin $branch
		else
			git add .
			git commit -m "${description:-wix-cli quick commit}"
			git push origin $branch
		fi
	fi
elif [ "$1" = "repo" ]; then
	echo "${GREEN}Redirecting to $repo_url..."
	xdg-open "https://github.com/$repo_url"

elif [ "$1" = "branch" ]; then
	echo "${GREEN}Redirecting to $branch on $repo_url..."
	xdg-open "https://github.com/$repo_url/tree/$branch"

elif [ "$1" = "nbranch" ]; then
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
	echo "${GREEN}Creating PR for $branch in $repo_url..."
	xdg-open "https://github.com/$repo_url/pull/new/$branch"
	
elif [ "$1" = "bpr" ]; then
	if [ $gt1 ]; then
		git checkout -b $2
		git add .
		git commit -m "wix-cli quick commit"
		git push origin $2
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
			echo "${GREEN}Creating PR for $branch in $repo_url..."
			xdg-open "https://github.com/$repo_url/pull/new/$branch"
		fi
	fi


# FILE CREATION

elif [[ "${exts[*]}" =~ "$1" ]]; then
	echo "${GREEN}Enter a filename for your $1 file:${RESET}"
	read fname
	echo "${GREEN}Creating $fname.$1"
	touch $fname.$1
	gedit $fname.$1	

	
# ERROR

else
	echo "${RED}Invalid command! Try again"
fi
