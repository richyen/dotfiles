#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")";

git pull origin master;

function installPython() {
  sudo apt install python3.8
  sudo apt install python3.8-distutils

  wget https://bootstrap.pypa.io/get-pip.py
  sudo python3.8 get-pip.py
  rm get-pip.py
}

function installDocker() {
  sudo apt-get update
  sudo apt-get -y install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
  sudo groupadd -aG docker ubuntu

}

function doIt() {
  cp .functions ~
  cp .aliases ~
  cp .gitconfig ~

  cat <<__EOF__ > ~/.bashrc
[ -n "\$PS1" ] && source ~/.bash_profile;
__EOF__

  cat <<__EOF__ > ~/.bash_profile
source ~/.exports_local >> ~/.bash_profile
for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
  [ -r "\$file" ] && [ -f "\$file" ] && source "\$file";
done;
unset file;
__EOF__
  source ~/.bash_profile;
  installDocker
  installPython
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
  doIt;
else
  read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
  echo "";
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    doIt;
  fi;
fi;
unset doIt;
