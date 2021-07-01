#!/usr/bin/env bash

if [[ -z "$RELEASE_TAG_NAME" ]] && [[ -z "$WORKER_VERSION" ]]; then
  echo "master"
  exit 0
fi

if [ ! -z "$WORKER_VERSION" ]; then
  echo "$WORKER_VERSION"
  exit 0
fi

echo "$RELEASE_TAG_NAME"
exit 0
