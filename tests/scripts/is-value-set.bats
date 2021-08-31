#!/usr/bin/env bats

setup() {
  load 'node_modules/bats-assert/load'
}

@test "is-value-set returns true when set" {
  export VALUE="set"
  run "${BATS_TEST_DIRNAME}"/../../scripts/is-value-set.sh

  assert_success
  assert_output "true"
}

@test "is-value-set returns false when not set" {
  run "${BATS_TEST_DIRNAME}"/../../scripts/is-value-set.sh

  assert_success
  assert_output "false"
}
