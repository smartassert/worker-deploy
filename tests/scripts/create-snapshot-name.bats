#!/usr/bin/env bats

export script_name=$(basename "$BATS_TEST_FILENAME" | sed 's/bats/sh/g')

setup() {
  load 'node_modules/bats-support/load'
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
  export EVENT_NAME=foo
  run main

  assert_failure "2"
}

@test "$script_name: fails with EVENT_NAME=pull_request and empty PR_NUMBER" {
  export EVENT_NAME=pull_request
  run main

  assert_failure "3"
}

@test "$script_name: fails with EVENT_NAME=release and empty VERSION" {
  export EVENT_NAME=release
  run main

    assert_failure "4"
}

@test "$script_name: fails with EVENT_NAME=workflow_dispatch and empty VERSION" {
  export EVENT_NAME=workflow_dispatch
  run main

    assert_failure "4"
}

@test "$script_name: succeeds with EVENT_NAME=push" {
  export EVENT_NAME=push
  run main

  assert_success
  assert_output "master"
}

@test "$script_name: succeeds with EVENT_NAME=pull_request, PR_NUMBER=101" {
  export EVENT_NAME=pull_request
  export PR_NUMBER="101"
  run main

  assert_success
  assert_output "pull-request-101"
}

@test "$script_name: succeeds with EVENT_NAME=release, VERSION=0.1" {
  export EVENT_NAME=release
  export VERSION=0.1
  run main

  assert_success
  assert_output "release-0.1"
}

@test "$script_name: succeeds with EVENT_NAME=release, VERSION='0.2'" {
  export EVENT_NAME=release
  export VERSION='0.2'
  run main

  assert_success
  assert_output "release-0.2"
}

@test "$script_name: succeeds with EVENT_NAME=workflow_dispatch, VERSION=0.3" {
  export EVENT_NAME=workflow_dispatch
  export VERSION=0.3
  run main

  assert_success
  assert_output "release-0.3"
}

@test "$script_name: succeeds with EVENT_NAME=workflow_dispatch, VERSION='0.4'" {
  export EVENT_NAME=workflow_dispatch
  export VERSION='0.4'
  run main

  assert_success
  assert_output "release-0.4"
}
