#!/bin/bash
function sshUpload {
    # Usage: 
    ## Argument 1 - Define source file/directory path for upload
    ## Argument 2 - Define upload desitination
    printf "\nPushing to server... \n"
    prompt=""
    read -rp "Remove local source files? Type NO if not sure. " prompt
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]];then
        rsync --verbose --recursive --info=progress2 --info=name0 --remove-source-files --rsh="ssh -p '$envPort' -i '$envIdentity'" "$1" "$envLogin:$2" \
        && printf "\nLocal source files removed. \n"
    else 
        rsync --verbose --recursive --info=progress2 --info=name0 --rsh="ssh -p '$envPort' -i '$envIdentity'" "$1" "$envLogin:$2" \
        && printf "\nLocal source files kept. \n"
    fi
}