#!/usr/bin/env bats

export script_name=$(basename "$BATS_TEST_FILENAME" | sed 's/bats/sh/g')

setup() {
  load 'node_modules/bats-assert/load'
}

main() {
  bash "${BATS_TEST_DIRNAME}/../../scripts/$script_name"
}

@test "$script_name: non-empty release tag name outputs release tag name" {
  export RELEASE_TAG_NAME="release-tag-name"

  run main

  assert_success
  assert_output "$RELEASE_TAG_NAME"
}

@test "$script_name: non-empty input version outputs input version" {
  export INPUT_VERSION="version"

  run main

  assert_success
  assert_output "$INPUT_VERSION"
}

@test "$script_name: empty release tag name and empty input version outputs 'master'" {
  run main

  assert_success
  assert_output "master"
}

@test "$script_name: non-empty release tag name and non-empty input version outputs release tag name" {
  export RELEASE_TAG_NAME="release-tag-name"
  export INPUT_VERSION="version"

  run main

  assert_success
  assert_output "$RELEASE_TAG_NAME"
}
