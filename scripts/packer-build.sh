#!/usr/bin/env bash

packer build "$IMAGE_DEFINITION" | tee "$PACKER_LOG_PATH"
IMAGE_ID=$(tail -1 "$PACKER_LOG_PATH" | grep -P -o 'ID: \d+' | tr -d 'ID: ')

if ! [[ $IMAGE_ID =~ ^[0-9]+$ ]] ; then
  exit 1
fi

echo "$IMAGE_ID" > "$IMAGE_ID_PATH"
