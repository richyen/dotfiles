#!/usr/bin/env bash

scp ~/.ssh/id_rsa ${1}:~/.ssh/
scp ~/.exports_local ${1}:~/
ssh ${1} "git clone https://github.com/richyen/dotfiles.git"
ssh ${1} "~/dotfiles/bootstrap.sh --force"
ssh ${1} "~/dotfiles/github.sh"
ssh ${1} "rm -rf ~/dotfiles"

echo "Done.  You may also need to:"
echo "  - Create symlink for TPA"
echo "  - Setup TPA"
