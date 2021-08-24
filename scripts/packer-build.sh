#!/usr/bin/env bash

packer build "$IMAGE_DEFINITION" | tee packer.log
IMAGE_ID=$(cat packer.log | tail -1 | grep -P -o 'ID: \d+' | tr -d 'ID: ')

if ! [[ $IMAGE_ID =~ ^[0-9]+$ ]] ; then
   exit 1
fi

export IMAGE_ID
