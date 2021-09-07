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

@test "$script_name: no arguments" {
  run main

  assert_success
  assert_output ""
}

@test "$script_name: non-empty VALUE1 outputs VALUE1" {
  VALUE1="release-tag-name"

  VALUE1="$VALUE1" \
  run main

  assert_success
  assert_output "$VALUE1"
}

@test "$script_name: non-empty VALUE2 outputs VALUE2" {
  VALUE2="version"

  VALUE2="$VALUE2" \
  run main

  assert_success
  assert_output "$VALUE2"
}

@test "$script_name: empty VALUE1 and VALUE2 outputs DEFAULT" {
  DEFAULT="master" \
  run main

  assert_success
  assert_output "master"
}

@test "$script_name: non-empty VALUE1 and non-empty VALUE2 outputs VALUE1" {
  VALUE1="release-tag-name"
  VALUE2="version"

  VALUE1="$VALUE1" \
  VALUE2="$VALUE2" \
  run main

  assert_success
  assert_output "$VALUE1"
}
