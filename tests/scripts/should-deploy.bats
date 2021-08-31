#!/usr/bin/env bats

script_name=$(basename "$BATS_TEST_FILENAME" | sed 's/bats/sh/g')
export script_name

setup() {
  load 'node_modules/bats-assert/load'
}

main() {
  bash "${BATS_TEST_DIRNAME}/../../scripts/$script_name"
}

@test "$script_name: no arguments outputs 'false'" {
  run main

  assert_success
  assert_output "false"
}

@test "$script_name: event name not 'release' and input should deploy not 'true' outputs 'false'" {
  EVENT_NAME="push" \
  INPUT_SHOULD_DEPLOY="false" \
  run main

  assert_success
  assert_output "false"
}

@test "$script_name: event name not 'release' and input should deploy 'true' outputs 'true'" {
  EVENT_NAME="push" \
  INPUT_SHOULD_DEPLOY="true" \
  run main

  assert_success
  assert_output "true"
}

@test "$script_name: event name 'release' and input should deploy not 'true' outputs 'true'" {
  EVENT_NAME="release" \
  INPUT_SHOULD_DEPLOY="false" \
  run main

  assert_success
  assert_output "true"
}

@test "$script_name: event name 'release' and input should deploy 'true' outputs 'true'" {
  EVENT_NAME="release" \
  INPUT_SHOULD_DEPLOY="true" \
  run main

  assert_success
  assert_output "true"
}
