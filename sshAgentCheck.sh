#!/bin/bash
# Deprecated:
##eval `ssh-agent -s` # Start ssh-agent to limit pw re-entry per https://stackoverflow.com/questions/17846529/could-not-open-a-connection-to-your-authentication-agent
##ssh-add "$envIdentity" # Loading the selected key specified in the environments.json

# SSH Agent check or start
printf "Checking if ssh-agent is running... \n"
function sshAddIdentity {
    if [[ "$envIdentity" ]];then
        # Identity filepath is specified already.
        echo ""&>/dev/null
    else
        read -p "Environment identity not set. Specify SSH identity file path: " envIdentity
    fi
    # Loading the selected key for 4 hours, kills ssh-agent on exit
    ssh-add -t 4h "$envIdentity" \
    && trap "ssh-agent -k" exit \
    && printf "SSH identity added for 2 hours. \n"
}
ssh-add -l &>/dev/null
if [ "$?" == 2 ]; then
    # If no existing fingerprints, then load any stored agent connection info if available.
    test -r ~/.ssh-agent && \
       source ~/.ssh-agent >/dev/null
        # If there is a stored ssh-agent, load the agent process and try listing ssh-agent fingerprints again.
    ssh-add -l &>/dev/null
    if [ "$?" == 2 ]; then
        # If the stored ssh-agent won't start or doesn't exist, create a new ssh-agent and store in private file
        (umask 066; ssh-agent > ~/.ssh-agent) \
        && printf "Started ssh-agent. \n"
        source ~/.ssh-agent >/dev/null \
        && sshAddIdentity
    fi
elif [ "$?" == 1 ]; then
    sshAddIdentity
else
    printf "Confirmed ssh-agent with an identity is running. \n"
fi