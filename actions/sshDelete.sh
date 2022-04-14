#!/bin/bash
function sshDelete {
    # Usage: Define files to be deleted on remote server
    prompt=""
    printf "\n"
    read -rp "Confirm deletion of $1 [y/N]? " prompt
    printf "\nDeleting tmp files from server... \n"
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]];then
        # Declare and run function $1 within SSH shell and pass all arguments
        ssh -p "$envPort" -i "$envIdentity" "$envLogin" "rm -r $1" \
        && printf "\nRemote files removed. \n"
    else
        printf "\nRemote files left in place. \n"
    fi
}