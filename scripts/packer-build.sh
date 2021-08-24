#!/usr/bin/env bash

#packer build "$IMAGE_DEFINITION" | tee packer.log
#PACKER_LOG_CONTENTS=$(cat packer.log)
#IMAGE_ID=$(echo "$PACKER_LOG_CONTENTS" | tail -1 | grep -P -o 'ID: \d+' | tr -d 'ID: ')

IMAGE_ID=foo
PACKER_LOG_CONTENTS="log content goes here"

if ! [[ $IMAGE_ID =~ ^[0-9]+$ ]] ; then
   echo "$PACKER_LOG_CONTENTS"
   exit 1
fi

echo "$IMAGE_ID"
