#!/usr/bin/env bash

URL="https://raw.githubusercontent.com/smartassert/worker-deploy/$VERSION/image-versions.env"

STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$URL")

if [ "200" != "$STATUS_CODE" ]; then
  echo "URL: $URL"
  echo "Status code: $STATUS_CODE"
  exit 1
fi

#(export echo $(cat image-versions.env | tr '\n' ' ')

#curl -s -o image-versions.env "$URL"
CONTENT=$(curl -s "$URL")

for VALUE in $CONTENT; do
  export echo "$VALUE"
done
