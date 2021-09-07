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

@test "$script_name: non-empty release tag name outputs release tag name" {
  RELEASE_TAG_NAME="release-tag-name"

  RELEASE_TAG_NAME="$RELEASE_TAG_NAME" \
  run main

  assert_success
  assert_output "$RELEASE_TAG_NAME"
}

@test "$script_name: non-empty input version outputs input version" {
  INPUT_VERSION="version"

  INPUT_VERSION="$INPUT_VERSION" \
  run main

  assert_success
  assert_output "$INPUT_VERSION"
}

@test "$script_name: empty release tag name and empty input version outputs 'master'" {
  DEFAULT="master" \
  run main

  assert_success
  assert_output "master"
}

@test "$script_name: non-empty release tag name and non-empty input version outputs release tag name" {
  RELEASE_TAG_NAME="release-tag-name"
  INPUT_VERSION="version"

  RELEASE_TAG_NAME="$RELEASE_TAG_NAME" \
  INPUT_VERSION="$INPUT_VERSION" \
  run main

  assert_success
  assert_output "$RELEASE_TAG_NAME"
}
