#!/bin/bash

data_to_edit="$1"
if ! arggt "1"; then
    sys.info "What data would you like to edit?"
    read -r data_to_edit_prompt
    data_to_edit=$data_to_edit_prompt

    declare -a datanames
    datanames=( "user" "myorgs" "mydirs" "myscripts" )
    if ! printf '%s\0' "${datanames[@]}" | grep -Fxqz -- "$data_to_edit_prompt"; then
        sys.error "'$data_to_edit_prompt' is not a valid piece of data, please try one of the following: ${datanames[*]}"
        return 1
    fi
fi
if [ "$data_to_edit" = "user" ]; then
    editfile "$datadir/git-user.txt"
elif [ "$data_to_edit" = "myorgs" ]; then
    editfile "$datadir/git-orgs.txt"
elif [ "$data_to_edit" = "mydirs" ]; then
    editfile "$datadir/dir-aliases.txt"
elif [ "$data_to_edit" = "myscripts" ]; then
    editfile "$datadir/run-configs.txt"
elif [ "$data_to_edit" = "todo" ]; then
    editfile "$datadir/todo.txt"
fi