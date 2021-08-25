#!/usr/bin/env bash

CONTENT=$(cat "$STDERR_FILE")

if [ "" != "$CONTENT" ]; then
  ALLOWED_ERROR_COUNT=$(echo "$CONTENT" | grep "toomanyrequests" | grep -o "docker.com/increase-rate-limit" | wc -l)

  if [ 0 -eq "$ALLOWED_ERROR_COUNT" ]; then
    echo "$CONTENT"
    exit 1
  fi
fi
