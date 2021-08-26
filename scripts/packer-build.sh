#!/usr/bin/env bash

PACKER_OUTPUT=$(packer build "$IMAGE_DEFINITION" | tee packer.log)
IMAGE_ID=$(echo "$PACKER_OUTPUT" | tail -1 | grep -P -o 'ID: \d+' | tr -d 'ID: ')

if ! [[ $IMAGE_ID =~ ^[0-9]+$ ]] ; then
  echo "$PACKER_OUTPUT"
  exit 1
fi

echo "$IMAGE_ID"
