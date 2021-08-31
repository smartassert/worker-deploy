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
    echo "- compiler: 0.1"
    echo "- chrome runner: 0.2"
    echo "- firefox runner: 0.3"
    echo "- delegator: 0.4"
    echo "- worker: 0.5"
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
