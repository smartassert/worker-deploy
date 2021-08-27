#!/usr/bin/env bash

if [ -z "$EXPECTED_EXISTS" ]; then
  EXPECTED_EXISTS="true"
fi

if [ "$EXPECTED_EXISTS" != "true" ] && [ "$EXPECTED_EXISTS" != "false" ]; then
  EXPECTED_EXISTS="true"
fi

AUTH_HEADER="Authorization: Bearer ${DIGITALOCEAN_API_TOKEN}"
URL="https://api.digitalocean.com/v2/snapshots/${IMAGE_ID}"

RESPONSE_JSON=$(curl -s -X GET -H 'Content-Type: application/json' -H "${AUTH_HEADER}" "${URL}")
RESPONSE_JSON_HAS_SNAPSHOT=$(echo "$RESPONSE_JSON" | jq 'has("snapshot")')

exit "$([ "$RESPONSE_JSON_HAS_SNAPSHOT" = "$EXPECTED_EXISTS" ] && echo 0 || echo 1)"
