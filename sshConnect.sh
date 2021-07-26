#!/bin/bash
SRC=$(realpath "${BASH_SOURCE[0]}")
DIR="$(dirname "$SRC")"

# Check to ensure jq and rsync is installed
source "$DIR/tests/checkJq.sh"
source "$DIR/tests/checkRsync.sh"

# Load environments.json config file and store as variable
source "$DIR/vars/configToVars"

# Select environment to work from to set environment variables
envNumbers=() # Declare empty array
for i in "${!environmentsNames[@]}"; do 
    envNumbers+=($i) # Create array of environment numbers so it can be checked against later
    printf "%s\t%s\n" "$i" "${environmentsNames[$i]}"  # List environment names from environments.json file
done
chosenEnv=""
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

# Load selected environment's details
source "$DIR/vars/envDetails"

# SSH Agent check/start
source "$DIR/sshAgentCheck.sh"

# Load action functions
# source "$DIR/actions/sshRun.sh"
# source "$DIR/actions/sshUpload.sh"
# source "$DIR/actions/sshDownload.sh"
# Or try this...
# for file find "$DIR/actions" -name "*.sh" | while read FILE
#     do source "$FILE"
# done

while IFS=  read -r -d $'\0'; do
    source "$REPLY"
done < <(find "$DIR/actions" -name "*.sh" -print0)

# Call an action function to do something