#!/usr/bin/env bash
# Author: Jon Tornetta https://github.com/jmtornetta
# Usage: Type -h or --help for usage instructions
initialize () {
    local DIR
    DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
    local LOG="$DIR/${BASH_SOURCE[0]}.log"

    # Check to ensure jq and rsync is installed
    source "$DIR/tests/checkJq.sh"
    source "$DIR/tests/checkRsync.sh"

    # Load environments.json config file and store as variable
    # source "$DIR/vars/configToVars" # 08/18/2021 JT - old, pulling these defines in to this script
    configJSON=$(jq '.' "$DIR/config.json") # Returns all environment data in variable to save energy
    mapfile -t environmentsNames < <(jq -r '.environments[].name' <<< "${configJSON}" | tr -d '\r') # Returns an array of environment names
    
    # Select environment to work from to set environment variables
    envNumbers=() # Declare empty array
body () {
    set -Eeuo pipefail
    trap cleanup SIGINT SIGTERM ERR EXIT
usage() {
    cat <<- EOF
    USAGE: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-f] -p param_value arg1 [arg2...]
    
    The goal for easy-ssh is to make using common ssh commands, identities, ssh-agent, and environments 
    more convenient and less messy. 
    
    Predefine your common ssh environments with your private key identities, run local functions easily 
    in your remote environment, and upload and download directories more quickly with rsync.

    OPTIONS:
       -v --verbose             Verbose
       -h --help                Show this help message.
          --no-color            Remove output colors.
       
    CREDITS: 
        1) https://betterdev.blog/minimal-safe-bash-script-template/
        2) http://kfirlavi.herokuapp.com/blog/2012/11/14/defensive-bash-programming/
EOF
}
    cleanup() {
        trap - SIGINT SIGTERM ERR EXIT
        # script cleanup here
    }
    setupColors() {
        if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
            NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
        else
            # shellcheck disable=SC2034  # Unused variables left for readability
            NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
        fi
    }
    msg() {
        echo >&2 -e "${1-}"
    }

    die() {
        local msg=$1
        local code=${2-1} # default exit status 1
        msg "$msg"
        exit "$code"
    }

    parseParams() {
        # default values of variables set from params
        flag=0
        param=''

        while :; do
            case "${1-}" in
            -h | --help) usage ;;
            -v | --verbose) set -x ;;
            #-f | --flag) flag=1 ;; # example flag
            #-p | --param) ;; # example required named parameter
            --no-color) NO_COLOR=1
            # param="${2-}" # example if parameter is required
            shift
            ;;
            -?*) die "Unknown option: $1" ;;
            *) break ;;
            esac
            shift
        done

        args=("$@")

        # check required params and arguments
        #[[ -z "${param-}" ]] && die "Missing required parameter: param" # if parameter is required
        [[ ${#args[@]} -eq 0 ]] && die "Missing script arguments" # if argumment is required

        return 0
    }

    parseParams "$@"
    setupColors

#~~ BEGIN SCRIPT ~~#
sshConnect () {
    for i in "${!environmentsNames[@]}"; do 
        envNumbers+=("$i") # Create array of environment numbers so it can be checked against later
        printf "%s\t%s\n" "$i" "${environmentsNames[$i]}"  # List environment names from environments.json file
    done
    chosenEnv=""
    for i in 1 2 3; do # Three attempts to select the right environment
        printf '\n'
        read -rp "Enter the number of the environment to work from. Use staging by default. " chosenEnv
        if [[ ! "${envNumbers[*]}" =~ $chosenEnv ]]; then # Checks the concatenated array for chosenEnv and repeat for loop
            printf '\n%s\n' "Your entry $chosenEnv is not a valid environment number."
        else
            echo "You selected '$chosenEnv' which represents '${environmentsNames[$chosenEnv]}'"
            break # Leaves the loop if environment is valid
        fi
        if [[ $i == 3 ]]; then # On last try, exit the script
            printf '\n%s\n' "You did not select a valid environment. Goodbye."
            sleep 5
            exit 1 # Leaves the script
        fi
        printf '\n%s\n' "Try again."
    done

    # Or try this...
    # for file find "$DIR/actions" -name "*.sh" | while read FILE
    #     do source "$FILE"
    # done

    while IFS=  read -r -d $'\0'; do
        source "$REPLY"
    done < <(find "$DIR/actions" -name "*.sh" -print0)

        # Call an action function to do something
        }

    msg "${RED}Read parameters:${NOFORMAT}"
    msg "- flag: ${flag}"
    msg "- param: ${param}"
    msg "- arguments: ${args[*]-}"
}
printf '\n\n%s\n\n' "---$(date)---" >> "$LOG"
body "$@" |& tee -a "$LOG"
}
initialize