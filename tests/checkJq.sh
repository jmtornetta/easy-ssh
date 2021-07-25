if ! command -v jq &> /dev/null
then
    echo "jq command could not be found. Install jq before using easy-ssh. See https://github.com/stedolan/jq/releases. Exiting..."
    sleep 5s
    exit 1
fi