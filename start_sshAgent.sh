#!/bin/bash
# About: Starts ssh-agent with an expiry and loads previous agent environment if available.
# Credit: https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/working-with-ssh-key-passphrases#platform-windows

start() {
    # set -Eeuo pipefail # Posterity: Removed for .bashrc sourcing so terminal does not immediately close if errors.
    declare -r sshDir="${4:-$HOME/.ssh}" # declare first because dependencies below, but last argument because least likely to be changed
    declare -r sshKey="${1:-$sshDir/id_rsa}" # the key for agent to load
    declare -r agentEnv="${2:-$sshDir/agent.env}" # the agent environment location
    declare -r sshAgentTime="${3:-4h}" # time before key revalidation
    declare agentRunState

    function load_agent { 
        # shellcheck source=/dev/null
        [ -r "$agentEnv" ] && source "$agentEnv" >| /dev/null ; 
        }

    function launch_agent {
        (umask 077; ssh-agent >| "$agentEnv")
        # shellcheck source=/dev/null
        source "$agentEnv" >| /dev/null
    }

    function add_agentIdentity {
        ssh-add -t "$sshAgentTime" "$sshKey" || { echo "Error: Could not add identity." && return 1 ; }
        trap "ssh-agent -k" EXIT
        echo "SSH identity added for $sshAgentTime." 
    }

    load_agent || true # If cannot load agent, still return true to prevent errors
    agentRunState=$(ssh-add -l >| /dev/null 2>&1; echo $?)
    #^ agentRunState: 0=agent running w/ key; 1=agent w/o key; 2= agent not running

    if [ ! "$SSH_AUTH_SOCK" ] || [ "$agentRunState" = 2 ]; then
        launch_agent
        add_agentIdentity
    elif [ "$SSH_AUTH_SOCK" ] && [ "$agentRunState" = 1 ]; then
        add_agentIdentity
    fi
}
start "$@"