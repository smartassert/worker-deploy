#!/usr/bin/env bats

setup() {
  load 'node_modules/bats-support/load'
  load 'node_modules/bats-assert/load'
}

main() {
  bash "${BATS_TEST_DIRNAME}"/../../scripts/set-version.sh
}

@test "set-version non-empty release tag name set as release tag name" {
  export RELEASE_TAG_NAME="release-tag-name"

  run main

  assert_success
  assert_output "$RELEASE_TAG_NAME"
}

@test "set-version non-empty input version set as version" {
  export INPUT_VERSION="version"

  run main

  assert_success
  assert_output "$INPUT_VERSION"
}

@test "set-version empty release tag name and empty input version as set 'master'" {
  run main

  assert_success
  assert_output "master"
}

@test "set-version non-empty release tag name and non-empty input version as set release tag name" {
  export RELEASE_TAG_NAME="release-tag-name"
  export INPUT_VERSION="version"

  run main

  assert_success
  assert_output "$RELEASE_TAG_NAME"
}
