#!/usr/bin/env bash

packer build "$IMAGE_DEFINITION" | tee packer.log
IMAGE_ID=$(tail -1 packer.log | grep -P -o 'ID: \d+' | tr -d 'ID: ')

if ! [[ $IMAGE_ID =~ ^[0-9]+$ ]] ; then
   exit 1
fi

echo "$IMAGE_ID"
