#!/usr/bin/env bats

setup() {
  load 'node_modules/bats-support/load'
  load 'node_modules/bats-assert/load'
}

main() {
  bash "${BATS_TEST_DIRNAME}"/../../scripts/should-deploy.sh
}

@test "should-deploy no arguments set as 'false'" {
  run main

  assert_success
  assert_output "false"
}

@test "should-deploy event name not 'release' and input should deploy not 'true' set as 'false'" {
  export EVENT_NAME="push"
  export INPUT_SHOULD_DEPLOY="false"

  run main

  assert_success
  assert_output "false"
}

@test "should-deploy event name not 'release' and input should deploy 'true' set as 'true'" {
  export EVENT_NAME="push"
  export INPUT_SHOULD_DEPLOY="true"

  run main

  assert_success
  assert_output "true"
}

@test "should-deploy event name 'release' and input should deploy not 'true' set as 'true'" {
  export EVENT_NAME="release"
  export INPUT_SHOULD_DEPLOY="false"

  run main

  assert_success
  assert_output "true"
}

@test "should-deploy event name 'release' and input should deploy 'true' set as 'true'" {
  export EVENT_NAME="release"
  export INPUT_SHOULD_DEPLOY="true"

  run main

  assert_success
  assert_output "true"
}
