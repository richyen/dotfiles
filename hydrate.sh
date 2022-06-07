#!/usr/bin/env bash

### This script will hydrate an EC2 or other remote instance
### To be run locally from a laptop or other client node
### Takes in single argument as "user@hostname"

scp ~/.ssh/id_rsa ${1}:~/.ssh/
scp ~/.exports_local ${1}:~/
ssh ${1} "git clone https://github.com/richyen/dotfiles.git"
ssh ${1} "~/dotfiles/bootstrap.sh --force"
ssh ${1} "~/dotfiles/github.sh"
ssh ${1} "rm -rf ~/dotfiles"

echo "Done.  You may also need to:"
echo "  - Create symlink for TPA"
echo "  - Setup TPA"
echo "  - Install any python libs"
