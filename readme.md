# [REWORK] Purpose
The goal for easy-ssh is to make using common ssh commands, identities, ssh-agent, and environments more convenient and less messy. Predefine your common ssh environments with your private key identities, run local functions easily in your remote environment, and upload and download directories more quickly with rsync.

# [REWORK] Getting Started
1. Install **jq** before using easy-ssh (`sudo apt-get install jq`). See https://github.com/stedolan/jq/releases.
2. Copy and rename **example-config.json** to **config.json**.
3. Add your SSH credentials to the **config.json** file. Adjust read/write/execute file permissions as needed. Keep this file ignored in **.gitignore**!
## [REWORK] sshConnect
1. Source **sshConnect.sh** to load and select environment.
    ```
    $ source sshConnect.sh 
    ```
2. Call desired action function. See list below.
## start_sshAgent.sh
1. Source **start_sshAgent.sh** to check and start ssh-agent
2. Note: Kept independent from **sshConnect.sh** so ssh-agent can be easily started from other scripts, without loading additional functions/files
# [REWORK] Functions for easy-ssh/sshConnect.sh
## sshRun
### Usage
1. Argument 1 - The locally defined function to pass and run in the remote shell environment
2. Arguments >=2 - Any arguments of the locally defined function to pass and run in the remote shell environment.
### Example
```
$ source sshConnect.sh 
$ sshRun "sampleFunction" "arg1" "arg2"
```
## sshDownload
### Usage
1. Argument 1 - Define source file/directory path to download
2. Argument 2 - Define download destination
### Example
```
$ source sshConnect.sh 
$ sshDownload "/home/downloadFile.txt" "~/Downloads/"
```
## sshUpload
### Usage
1. Argument 1 - Define source file/directory path for upload
2. Argument 2 - Define upload desitination
### Example
```
$ source sshConnect.sh 
$ sshUpload "~/Desktop/uploadFile.txt" "/home/uploads/" 
```
## sshDelete
### Usage
1. Argument 1 - Define the file/directory to delete
### Example
```
$ source sshConnect.sh 
$ sshDelete "tmp/deleteFolder"
```
# [REWORK] Future
1. Test sshRun function with different commands and arguments to make more widespread
1. Include 'js' and 'rsync' as submodules or replace with native tools (scp,grep)

3. Ensure specifying environment port optional, so if not specified in environments.json the default port is used
4. Configurable options for how long ssh-agent will retain identity in ssh-agent shell
5. Fix randmon console output error which displays the user's environment selection incorrectly. Example:
    ```
    Enter the number of the environment to work from. Use staging by default. 0
    'ou selected '0' which represents 'stg)
    ```

# Changelog
## 06/11/2022
+ Simplify `start_sshAgent.sh` so that it can be source easily on bash startup to auto-load keys.  
+ Merge conflicting changes.  
## 07/25/2021
1. Merge recommended ssh-agent functions from github (https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/working-with-ssh-key-passphrases#platform-windows)
2. Disabled read user prompts, made quiet