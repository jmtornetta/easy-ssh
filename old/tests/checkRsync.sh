#!/bin/bash
if ! command -v rsync &> /dev/null
then
    echo "rsync command could not be found. Install rsync and dependencies before using easy-ssh. Exiting..."
    sleep 5s
    exit 1
fi