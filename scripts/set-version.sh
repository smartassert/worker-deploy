#!/usr/bin/env bash

if [ "$RELEASE_TAG_NAME" != "" ]; then
  echo "$RELEASE_TAG_NAME"
elif [ "$INPUT_VERSION" != "" ]; then
  echo "$INPUT_VERSION"
else
  echo "master"
fi
