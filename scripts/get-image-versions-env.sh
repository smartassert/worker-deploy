#!/usr/bin/env bash

URL="https://raw.githubusercontent.com/smartassert/worker-deploy/$VERSION/image-versions.env"

STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$URL")

if [ "200" != "$STATUS_CODE" ]; then
  echo "URL: $URL"
  echo "Status code: $STATUS_CODE"
  exit 1
fi

for VALUE in $(curl -s "$URL"); do
  export echo "$VALUE"
done
