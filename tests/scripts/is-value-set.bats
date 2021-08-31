#!/usr/bin/env bats

script_name=$(basename "$BATS_TEST_FILENAME" | sed 's/bats/sh/g')
export script_name

setup() {
  load 'node_modules/bats-assert/load'
}

main() {
  bash "${BATS_TEST_DIRNAME}/../../scripts/$script_name"
}

@test "is-value-set returns true when set" {
  export VALUE="set"

  run main

  assert_success
  assert_output "true"
}

@test "is-value-set returns false when not set" {
  run main

  assert_success
  assert_output "false"
}
