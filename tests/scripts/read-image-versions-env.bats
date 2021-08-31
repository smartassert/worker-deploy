#!/usr/bin/env bats

export script_name=$(basename "$BATS_TEST_FILENAME" | sed 's/bats/sh/g')

setup() {
  load 'node_modules/bats-support/load'
  load 'node_modules/bats-assert/load'
}

main() {
  bash "${BATS_TEST_DIRNAME}/../../scripts/$script_name"
}

@test "$script_name: read is successful" {
  export ENV_FILE_PATH="${BATS_TEST_DIRNAME}/../scripts/fixtures/empty.env"

  run main

  assert_success
  assert_output "$(
    echo "::set-output name=COMPILER_VERSION::0.29"
    echo "::set-output name=CHROME_RUNNER_VERSION::0.18"
    echo "::set-output name=FIREFOX_RUNNER_VERSION::0.18"
    echo "::set-output name=DELEGATOR_VERSION::0.6"
    echo "::set-output name=WORKER_VERSION::0.5"
  )"
}
