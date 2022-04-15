#!/bin/bash
# Credit: https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/working-with-ssh-key-passphrases#platform-windows
# Updated: Added trap to kill ssh-agent for security and added default sshAgentTime so identity expires after a time

SRC=$(realpath "${BASH_SOURCE[0]}")
DIR="$(dirname "$SRC")"
env="$HOME/.ssh/agent.env"

# Check to ensure jq and rsync is installed
source "$DIR/tests/checkJq.sh"

# Load environments.json config file and store as variable
source "$DIR/vars/configToVars"

# shellcheck source=/dev/null
function agentLoadEnv { test -r "$env" && source "$env" >| /dev/null ; } 

function agentStart {
    (umask 077; ssh-agent >| "$env")
    # shellcheck source=/dev/null
    source "$env" >| /dev/null ; }

function agentAddIdentity {
    ssh-add -t "$sshAgentTime" "$envIdentity" \
    && trap "ssh-agent -k" exit \
    && printf "\n%s\n" "SSH identity added for $sshAgentTime." ; }

agentLoadEnv

# agentRunState: 0=agent running w/ key; 1=agent w/o key; 2= agent not running
agentRunState=$(ssh-add -l >| /dev/null 2>&1; echo $?)

if [ ! "$SSH_AUTH_SOCK" ] || [ "$agentRunState" = 2 ]; then
    agentStart
    agentAddIdentity
elif [ "$SSH_AUTH_SOCK" ] && [ "$agentRunState" = 1 ]; then
    agentAddIdentity
fi

unset env