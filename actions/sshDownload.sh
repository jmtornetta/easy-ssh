#!/bin/bash
function sshDownload {
    # Usage: 
    ## Argument 1 - Define source file/directory path to download
    ## Argument 2 - Define download destination
    printf "\nPulling from server... \n"
    prompt=""
    printf "\n"
    read -rp "Remove remote source files? Type NO if not sure. " prompt
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]];then
        rsync --verbose --recursive --remove-source-files --info=progress2 --info=name0 --rsh="ssh -p '$envPort' -i '$envIdentity'" "$envLogin:$1" "$2" \
        && printf "\nRemote source files removed. \n"
    else
        rsync --verbose --recursive --info=progress2 --info=name0 --rsh="ssh -p '$envPort' -i '$envIdentity'" "$envLogin:$1" "$2" \
        && printf "\nRemote source files kept. \n"
    fi
}