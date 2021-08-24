#!/usr/bin/env bash

if [ "$EVENT_NAME" = "release" ] || [ "$INPUT_SHOULD_DEPLOY" = "true" ]; then
  echo "true"
else
  echo "false"
fi
