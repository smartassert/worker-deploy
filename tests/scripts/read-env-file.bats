#!/usr/bin/env bats

export script_name=$(basename "$BATS_TEST_FILENAME" | sed 's/bats/sh/g')

setup() {
  load 'node_modules/bats-support/load'
  load 'node_modules/bats-assert/load'
}

main() {
  bash "${BATS_TEST_DIRNAME}/../../scripts/$script_name"
}

@test "$script_name: empty file" {
  export ENV_FILE_PATH="${BATS_TEST_DIRNAME}/../scripts/fixtures/empty.env"

  run main

  assert_success
  assert_output ""
}

@test "$script_name: single-item file" {
  export ENV_FILE_PATH="${BATS_TEST_DIRNAME}/../scripts/fixtures/single.env"

  run main

  assert_success
  assert_output "COMPILER_VERSION=0.29"
}

@test "$script_name: multi-item file" {
  export ENV_FILE_PATH="${BATS_TEST_DIRNAME}/../scripts/fixtures/multiple.env"

  run main

  assert_success
  assert_output "$(
    echo "COMPILER_VERSION=0.29"
    echo "CHROME_RUNNER_VERSION=0.18"
    echo "FIREFOX_RUNNER_VERSION=0.18"
  )"
}

@test "$script_name: multi-item file with blank lines between items" {
  export ENV_FILE_PATH="${BATS_TEST_DIRNAME}/../scripts/fixtures/multiple-with-blank-lines.env"

  run main

  assert_success
  assert_output "$(
    echo "COMPILER_VERSION=0.29"
    echo "CHROME_RUNNER_VERSION=0.18"
    echo "FIREFOX_RUNNER_VERSION=0.18"
  )"
}

@test "$script_name: multi-item file and output template" {
  export ENV_FILE_PATH="${BATS_TEST_DIRNAME}/../scripts/fixtures/multiple.env"
  export OUTPUT_TEMPLATE="!!_key_!!===*_value_*"

  run main

  assert_success
  assert_output "$(
    echo "!!COMPILER_VERSION!!===*0.29*"
    echo "!!CHROME_RUNNER_VERSION!!===*0.18*"
    echo "!!FIREFOX_RUNNER_VERSION!!===*0.18*"
  )"
}
