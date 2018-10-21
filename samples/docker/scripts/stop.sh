#!/bin/bash
echo "Stopping these following images?"
docker ps -a | grep '\indy_pool\|pico-agent' # | '{print $1}'
read -p "Are you sure? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    #docker stop $(docker ps -a | grep '\indy_pool\|pico-agent' | awk '{print $1}')
    docker stop $(docker ps -a | grep pico-agent' | awk '{print $1}')
fi