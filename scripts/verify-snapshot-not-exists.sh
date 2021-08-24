#!/usr/bin/env bash

EXIT_CODE_RESPONSE_ID_MISSING=1
EXIT_CODE_RESPONSE_ID_INCORRECT=3

AUTH_HEADER="Authorization: Bearer ${DIGITALOCEAN_API_TOKEN}"
URL="https://api.digitalocean.com/v2/snapshots/${IMAGE_ID}"

RESPONSE_JSON=$(curl -s -X GET -H 'Content-Type: application/json' -H "${AUTH_HEADER}" "${URL}")

RESPONSE_JSON_HAS_ID=$(echo "$RESPONSE_JSON" | jq 'has("id")')
if [ "$RESPONSE_JSON_HAS_ID" != "true" ]; then
  exit $EXIT_CODE_RESPONSE_ID_MISSING
fi

RESPONSE_ID=$(echo "$RESPONSE_JSON" | jq '.id')
EXPECTED_RESPONSE_ID="\"not_found\""

if [ "$RESPONSE_ID" != "$EXPECTED_RESPONSE_ID" ]; then
  exit $EXIT_CODE_RESPONSE_ID_INCORRECT
fi

echo "Snapshot ${IMAGE_ID} does not exist ✓"