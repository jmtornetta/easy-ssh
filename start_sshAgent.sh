#!/bin/bash
# About: Starts ssh-agent with an expiry and loads previous agent environment if available.
# Credit: https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/working-with-ssh-key-passphrases#platform-windows

start() {
    set -Eeuo pipefail # need to disable at bottom of script for .bashrc sourcing
    declare -r sshKey="${1:-$HOME/.ssh/id_rsa}"
    declare -r sshAgentTime="${2:-4h}"
    declare -r agentEnv="${3:-$HOME/.ssh/agent.env}"
    declare agentRunState

    function load_agent { 
        # shellcheck source=/dev/null
        test -r "$agentEnv" && source "$agentEnv" >| /dev/null ; 
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

    load_agent
    agentRunState=$(ssh-add -l >| /dev/null 2>&1; echo $?)
    #^ agentRunState: 0=agent running w/ key; 1=agent w/o key; 2= agent not running

    if [ ! "$SSH_AUTH_SOCK" ] || [ "$agentRunState" = 2 ]; then
        launch_agent
        add_agentIdentity
    elif [ "$SSH_AUTH_SOCK" ] && [ "$agentRunState" = 1 ]; then
        add_agentIdentity
    fi

    set +Eeuo pipefail # unset so that script can be sourced from within .bashrc
}
start "$@"