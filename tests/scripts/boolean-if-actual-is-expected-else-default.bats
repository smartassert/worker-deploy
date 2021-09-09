#!/usr/bin/env bats

script_name=$(basename "$BATS_TEST_FILENAME" | sed 's/bats/sh/g')
export script_name

setup() {
  load 'node_modules/bats-support/load'
  load 'node_modules/bats-assert/load'
}

main() {
  bash "${BATS_TEST_DIRNAME}/../../scripts/$script_name"
}

@test "$script_name: no arguments outputs 'true'" {
  run main

  assert_success
  assert_output "true"
}

@test "$script_name: actual not equals expected and default 'false' outputs 'false'" {
  EXPECTED="expected" \
  ACTUAL="actual" \
  DEFAULT="false" \
  run main

  assert_success
  assert_output "false"
}

@test "$script_name: actual not equals expected and default 'true' outputs 'true'" {
  EXPECTED="expected" \
  ACTUAL="actual" \
  DEFAULT="true" \
  run main

  assert_success
  assert_output "true"
}

@test "$script_name: actual equals expected and default 'false' outputs 'true'" {
  EXPECTED="expected" \
  ACTUAL="expected" \
  DEFAULT="false" \
  run main

  assert_success
  assert_output "true"
}

@test "$script_name: actual equals expected and default 'true' outputs 'true'" {
  EXPECTED="expected" \
  ACTUAL="expected" \
  DEFAULT="true" \
  run main

  assert_success
  assert_output "true"
}
