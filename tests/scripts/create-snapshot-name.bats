#!/usr/bin/env bats

script_name=$(basename "$BATS_TEST_FILENAME" | sed 's/bats/sh/g')
export script_name

setup() {
  load 'node_modules/bats-assert/load'
}

main() {
  bash "${BATS_TEST_DIRNAME}/../../scripts/$script_name"
}

@test "$script_name: fails with no arguments" {
  run main

  assert_failure "1"
}

@test "$script_name: fails with invalid EVENT_NAME" {
  EVENT_NAME=FOO \
  run main

  assert_failure "2"
}

@test "$script_name: fails with EVENT_NAME=pull_request and empty PR_NUMBER" {
  EVENT_NAME=pull_request \
  run main

  assert_failure "3"
}

@test "$script_name: fails with EVENT_NAME=release and empty VERSION" {
  EVENT_NAME=release \
  run main

    assert_failure "4"
}

@test "$script_name: fails with EVENT_NAME=workflow_dispatch and empty VERSION" {
  EVENT_NAME=workflow_dispatch \
  run main

    assert_failure "4"
}

@test "$script_name: succeeds with EVENT_NAME=push" {
  EVENT_NAME=push \
  run main

  assert_success
  assert_output "master"
}

@test "$script_name: succeeds with EVENT_NAME=pull_request, PR_NUMBER=101" {
  EVENT_NAME=pull_request \
  PR_NUMBER="101" \
  run main

  assert_success
  assert_output "pull-request-101"
}

@test "$script_name: succeeds with EVENT_NAME=release, VERSION=0.1" {
  EVENT_NAME=release \
  VERSION=0.1 \
  run main

  assert_success
  assert_output "release-0.1"
}

@test "$script_name: succeeds with EVENT_NAME=release, VERSION='0.2'" {
  EVENT_NAME=release \
  VERSION='0.2' \
  run main

  assert_success
  assert_output "release-0.2"
}

@test "$script_name: succeeds with EVENT_NAME=workflow_dispatch, VERSION=0.3" {
  EVENT_NAME=workflow_dispatch \
  VERSION=0.3 \
  run main

  assert_success
  assert_output "release-0.3"
}

@test "$script_name: succeeds with EVENT_NAME=workflow_dispatch, VERSION='0.4'" {
  EVENT_NAME=workflow_dispatch \
  VERSION='0.4' \
  run main

  assert_success
  assert_output "release-0.4"
}
