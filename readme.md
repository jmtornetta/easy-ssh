# Purpose
The goal for easy-ssh is to make using common ssh commands, identities, ssh-agent, and environments more convenient and less messy. Predefine your common ssh environments with your private key identities, run local functions easily in your remote environment, and upload and download directories more quickly with rsync.

# Future
1. Test sshRun function with different commands and arguments to make more widespread
1. Include 'js' and 'rsync' as submodules or replace with native tools (scp,grep)
2. Make read user prompts optional with parameters (quiet mode)
3. Ensure specifying environment port optional, so if not specified in environments.json the default port is used
4. Configurable options for how long ssh-agent will retain identity in ssh-agent shell
5. Fix randmon console output error which displays the user's environment selection incorrectly. Example:
    ```
    Enter the number of the environment to work from. Use staging by default. 0
    'ou selected '0' which represents 'stg)
    ```
# Getting Started
1. Install **jq** before using easy-ssh. See https://github.com/stedolan/jq/releases.
2. Copy and rename **example-environments.json** to **environments.json**.
3. Add your SSH credentials to the **environments.json** file. Adjust read/write/execute file permissions as needed. Keep this file ignored in **.gitignore**!
4. Call **sshConnect.sh** to load and select environment.
    ```
    $ source sshConnect.sh 
    ```
5. Call desired ssh function. See list below.

# Functions for easy-ssh
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