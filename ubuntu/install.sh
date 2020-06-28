#!/bin/bash

packageList=vim,zsh,git,tig,tmux
declare -a packageList=(
 "vim" "zsh" "git" "tig"
 "tmux" "bat" "curl" "apache2-utils"
 "docker.io docker-compose"
)

apt-get update

# ref:https://stackoverflow.com/a/8880633
for val in "${packageList[@]}"
do
	apt-get install ${val}
done
