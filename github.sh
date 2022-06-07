#!/usr/bin/env bash

PREFIX=${HOME}/code

# Install personal Github repos
mkdir -p ${PREFIX}/github
cd ${PREFIX}/github
for repo in toolbox dotfiles; do
  git clone git@github.com:richyen/${repo}.git
done

# Install Postgres projects
mkdir -p ${PREFIX}/pg
cd ${PREFIX}/pg
for repo in richyen/barman richyen/explain.depesz.com; do
  git clone git@github.com:${repo}.git
done

# Clone the PostgreSQL repo
git clone http://git.postgresql.org/git/postgresql.git

# OPTIONAL: Install any other repos
# REPOS=/path/to/repos.txt
# mkdir -p ${PREFIX}/other
# cd ${PREFIX}/other
# for repo in `cat ${REPOS}`; do
#   git clone git@github.com:${repo}.git
# done
