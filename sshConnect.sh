#!/bin/bash
SRC2=$(realpath "${BASH_SOURCE[0]}")
DIR2="$(dirname "$SRC2")"

# Check to ensure jq and rsync is installed
if ! command -v jq &> /dev/null
then
    echo "jq command could not be found. Install jq before using easy-ssh. See https://github.com/stedolan/jq/releases. Exiting..."
    sleep 5s
    exit 1
fi
if ! command -v rsync &> /dev/null
then
    echo "rsync command could not be found. Install rsync and dependencies before using easy-ssh. Exiting..."
    sleep 5s
    exit 1
fi

# Load environments.json config file and store as variable
environmentsJSON="$(jq -r '.environments' "$DIR2/environments.json")" # Returns all environment data
environmentsNames=($(jq -r '.[] | .name' <<< "${environmentsJSON}")) # Returns an array of environment names

# Select environment to work from to set environment variables
envNumbers=() # Declare empty array
for i in "${!environmentsNames[@]}"; do 
    envNumbers+=($i) # Create array of environment numbers so it can be checked against later
    printf "%s\t%s\n" "$i" "${environmentsNames[$i]}"  # List environment names from environments.json file
done
chosenEnv="" # Unset chosenEnv to prevent accidents
for i in 1 2 3; do # Three attempts to select the right environment
    printf '\n'
    read -p "Enter the number of the environment to work from. Use staging by default. " chosenEnv
    if [[ ! "${envNumbers[@]}" =~ "$chosenEnv" ]]; then # Checks to ensure environment is valid
        printf "Your entry $chosenEnv is not a valid environment number. \n"
    else
        echo "You selected '$chosenEnv' which represents '${environmentsNames[$chosenEnv]}'"
        break # Leaves the loop if environment is valid
    fi
    if [[ $i == 3 ]]; then # On last try, exit the script
        printf "You did not select a valid environment. Goodbye. \n"
        sleep 5
        exit 1 # Leaves the script
    fi
    printf "Try again. \n"
done

# Define local variables based on chosen environment in environments.json file
printf "Gathering environment credentials for selected environment from config file... \n"
envName=$(jq -r --argjson chosenEnv $chosenEnv '.[$chosenEnv].name' <<< "${environmentsJSON}")
envDomain=$(jq -r --argjson chosenEnv $chosenEnv '.[$chosenEnv].siteurl' <<< "${environmentsJSON}")
envUsername=$(jq -r --argjson chosenEnv $chosenEnv '.[$chosenEnv].username' <<< "${environmentsJSON}")
envAddress=$(jq -r --argjson chosenEnv $chosenEnv '.[$chosenEnv].address' <<< "${environmentsJSON}")
envPort=$(jq -r --argjson chosenEnv $chosenEnv '.[$chosenEnv].port' <<< "${environmentsJSON}")
envIdentity=$(jq -r --argjson chosenEnv $chosenEnv '.[$chosenEnv].identity' <<< "${environmentsJSON}")
envLogin="$envUsername@$envAddress"
envPath=$(jq -r --argjson chosenEnv $chosenEnv '.[$chosenEnv].path' <<< "${environmentsJSON}")

# SSH Agent check/start
source "$DIR2/sshAgentCheck.sh"

function sshRun {
    # Usage: First argument is function to run, all additional are arguments for said function
    # eval `ssh-agent -s` # Start ssh-agent to limit pw re-entry per https://stackoverflow.com/questions/17846529/could-not-open-a-connection-to-your-authentication-agent
    ssh -p "$envPort" -i "$envIdentity" "$envLogin" "$(declare -f $1); $@" # Declare and run function $1 within SSH shell and pass all arguments
}
function sshDownload {
    # Usage: 
    ## Argument 1 - Define source file/directory path to download
    ## Argument 2 - Define download destination
    printf "\nPulling from server... \n"
    prompt=""
    printf "\n"
    read -p "Remove remote source files? Type NO if not sure. " prompt
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]];then
        rsync --verbose --recursive --remove-source-files --info=progress2 --info=name0 --rsh="ssh -p '$envPort' -i '$envIdentity'" "$envLogin:$1" "$2" \
        && printf "\nRemote source files removed. \n"
    else
        rsync --verbose --recursive --info=progress2 --info=name0 --rsh="ssh -p '$envPort' -i '$envIdentity'" "$envLogin:$1" "$2" \
        && printf "\nRemote source files kept. \n"
    fi
}
function sshUpload {
    # Usage: 
    ## Argument 1 - Define source file/directory path for upload
    ## Argument 2 - Define upload desitination
    printf "\nPushing to server... \n"
    prompt=""
    read -p "Remove local source files? Type NO if not sure. " prompt
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]];then
        rsync --verbose --recursive --info=progress2 --info=name0 --remove-source-files --rsh="ssh -p '$envPort' -i '$envIdentity'" "$1" "$envLogin:$2" \
        && printf "\nLocal source files removed. \n"
    else 
        rsync --verbose --recursive --info=progress2 --info=name0 --rsh="ssh -p '$envPort' -i '$envIdentity'" "$1" "$envLogin:$2" \
        && printf "\nLocal source files kept. \n"
    fi
}
function sshDelete {
    # Usage: Define files to be deleted on remote server
    prompt=""
    printf "\n"
    read -p "Confirm deletion of $1 [y/N]? " prompt
    printf "\nDeleting tmp files from server... \n"
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]];then
        # Declare and run function $1 within SSH shell and pass all arguments
        ssh -p "$envPort" -i "$envIdentity" "$envLogin" "rm -r $1" \
        && printf "\nRemote files removed. \n"
    else
        printf "\nRemote files left in place. \n"
    fi
}