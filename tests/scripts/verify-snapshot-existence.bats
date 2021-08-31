#!/usr/bin/env bats

script_name=$(basename "$BATS_TEST_FILENAME" | sed 's/bats/sh/g')
export script_name

setup() {
  load 'node_modules/bats-assert/load'

  export DIGITALOCEAN_API_TOKEN="token"
  export IMAGE_ID="12345"
}

main() {
  bash "${BATS_TEST_DIRNAME}/../../scripts/$script_name"
}

@test "$script_name: api returns non-json response" {
  function curl() {
    echo "non-json content"
  }

  export -f curl

  run main

  assert_failure "3"

  expected_output=$(
    echo "Invalid API response:"
    echo "non-json content"
    echo "jq exit code: 4"
  )

  assert_output "$expected_output"
}

@test "$script_name: snapshot does not exist, EXPECT_EXISTS not set" {
  function curl() {
    echo '{"id":"not_found","message":"The resource you were accessing could not be found."}'
  }

  export -f curl

  run main

  assert_failure "1"
  assert_output ""
}

@test "$script_name: snapshot does not exist, EXPECT_EXISTS not valid" {
  function curl() {
    echo '{"id":"not_found","message":"The resource you were accessing could not be found."}'
  }

  export -f curl

  EXPECTED_EXISTS="invalid value" \
  run main

  assert_failure "1"
  assert_output ""
}

@test "$script_name: snapshot does not exist, EXPECTED_EXISTS=true" {
  function curl() {
    echo '{"id":"not_found","message":"The resource you were accessing could not be found."}'
  }

  export -f curl

  EXPECTED_EXISTS="true" \
  run main

  assert_failure "1"
  assert_output ""
}

@test "$script_name: snapshot does not exist, EXPECTED_EXISTS=false" {
  function curl() {
    echo '{"id":"not_found","message":"The resource you were accessing could not be found."}'
  }

  export -f curl

  EXPECTED_EXISTS="false" \
  run main

  assert_success
  assert_output ""
}

@test "$script_name: snapshot does exist, EXPECTED_EXISTS not set" {
  function curl() {
    echo '{"snapshot":{}}'
  }

  export -f curl

  run main

  assert_success
  assert_output ""
}

@test "$script_name: snapshot does exist, EXPECTED_EXISTS not valid" {
  function curl() {
    echo '{"snapshot":{}}'
  }

  export -f curl

  EXPECTED_EXISTS="invalid value" \
  run main

  assert_success
  assert_output ""
}

@test "$script_name: snapshot does exist, EXPECTED_EXISTS=false" {
  function curl() {
    echo '{"snapshot":{}}'
  }

  export -f curl

  EXPECTED_EXISTS="false" \
  run main

  assert_failure "1"
  assert_output ""
}

@test "$script_name: snapshot does exist, EXPECTED_EXISTS=true" {
  function curl() {
    echo '{"snapshot":{}}'
  }

  export -f curl

  EXPECTED_EXISTS="true" \
  run main

  assert_success
  assert_output ""
}
