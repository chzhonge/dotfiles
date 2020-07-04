#!/bin/bash

declare -a packageList=(
 "vim" "zsh" "git" "tig"
 "tmux" "bat" "curl" "apache2-utils"
 "docker.io docker-compose"
)

declare -a dockerImageList=(
 "php:7.3-cli-alpine" "php:7.3.19-fpm-alpine"
 "composer:2.0.0-alpha2" "memcached:1.6.6-alpine"
 "nginx:1.19.0" "mysql:5.7.30" "phpmyadmin/phpmyadmin"
)

apt-get update

# ref:https://stackoverflow.com/a/8880633
for val in "${packageList[@]}"
do
	apt-get install ${val}
done

for val in "${dockerImageList[@]}"
do
        docker pull ${val}
done
