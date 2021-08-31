#!/usr/bin/env bats

export script_name=$(basename "$BATS_TEST_FILENAME" | sed 's/bats/sh/g')

setup() {
  load 'node_modules/bats-support/load'
  load 'node_modules/bats-assert/load'

  export COMPILER_VERSION="0.1"
  export CHROME_RUNNER_VERSION="0.2"
  export FIREFOX_RUNNER_VERSION="0.3"
  export DELEGATOR_VERSION="0.4"
  export WORKER_VERSION="0.5"

  export expected_content=$(
    echo "COMPILER_VERSION=0.1"
    echo "CHROME_RUNNER_VERSION=0.2"
    echo "FIREFOX_RUNNER_VERSION=0.3"
    echo "DELEGATOR_VERSION=0.4"
    echo "WORKER_VERSION=0.5"
  )
}

main() {
  bash "${BATS_TEST_DIRNAME}/../../scripts/$script_name"
}

@test "$script_name: content is created" {
  run main

  assert_success
  assert_output "${expected_content}"
}
