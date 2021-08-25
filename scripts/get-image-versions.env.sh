#!/usr/bin/env bash

URL="https://raw.githubusercontent.com/smartassert/worker-deploy/$VERSION/image-versions.env"

STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" $URL)

if [ "200" = "$STATUS_CODE" ]; then
  curl -s -o image-versions.env $URL
else
  exit 1
fi
