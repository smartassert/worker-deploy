#!/usr/bin/env bats

script_name=$(basename "$BATS_TEST_FILENAME" | sed 's/bats/sh/g')
export script_name

setup() {
  load 'node_modules/bats-assert/load'

  export COMPILER_VERSION="0.1"
  export CHROME_RUNNER_VERSION="0.2"
  export FIREFOX_RUNNER_VERSION="0.3"
  export DELEGATOR_VERSION="0.4"
  export WORKER_VERSION="0.5"

  export expected_content="COMPILER_VERSION=0.1
CHROME_RUNNER_VERSION=0.2
FIREFOX_RUNNER_VERSION=0.3
DELEGATOR_VERSION=0.4
WORKER_VERSION=0.5"
}

main() {
  bash "${BATS_TEST_DIRNAME}/../../scripts/$script_name"
}

@test "$script_name: content is created" {
  run main

  assert_success
  assert_output "${expected_content}"
}
