#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")";

git pull origin master;

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
