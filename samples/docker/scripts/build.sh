#!/bin/bash

#docker build -f indy-pool.dockerfile -t indy_pool .
#echo "Finished building indy_pool image"
docker build -f pico-agent.dockerfile -t pico-agent .
echo "Finished building pico-agent image"