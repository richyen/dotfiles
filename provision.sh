#!/usr/bin/env bash

scp ~/.ssh/id_rsa ${1}:~/.ssh/
ssh ${1} "git clone https://github.com/richyen/dotfiles.git"
ssh ${1} "~/dotfiles/bootstrap.sh --force"
ssh ${1} "~/dotfiles/github.sh"
