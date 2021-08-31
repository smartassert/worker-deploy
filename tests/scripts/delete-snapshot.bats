#!/usr/bin/env bats

export script_name=$(basename "$BATS_TEST_FILENAME" | sed 's/bats/sh/g')

setup() {
  load 'node_modules/bats-support/load'
  load 'node_modules/bats-assert/load'

  export DIGITALOCEAN_API_TOKEN="token"
  export IMAGE_ID="12345"

  function curl() {
    echo "$1 $2 $3 $4 $5 $6 $7 $8"
  }

  export -f curl
}

main() {
  bash "${BATS_TEST_DIRNAME}/../../scripts/$script_name"
}

@test "$script_name: request is formed correctly" {
  run main

  assert_success
  assert_output "-s -X DELETE -H Content-Type: application/json -H Authorization: Bearer $DIGITALOCEAN_API_TOKEN https://api.digitalocean.com/v2/snapshots/$IMAGE_ID"
}
