function sshRun {
    # Usage: First argument is function to run, all additional are arguments for said function
    # eval `ssh-agent -s` # Start ssh-agent to limit pw re-entry per https://stackoverflow.com/questions/17846529/could-not-open-a-connection-to-your-authentication-agent
    ssh -p "$envPort" -i "$envIdentity" "$envLogin" "$(declare -f $1); $@" # Declare and run function $1 within SSH shell and pass all arguments
}