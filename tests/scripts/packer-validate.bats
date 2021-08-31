#!/usr/bin/env bats

setup() {
  load 'node_modules/bats-support/load'
  load 'node_modules/bats-assert/load'

  export IMAGE_DEFINITION="image.pkr.hcl"
}

main() {
  bash "${BATS_TEST_DIRNAME}"/../../scripts/packer-validate.sh
}

@test "packer validate call is formed successfully" {
  function packer() {
    echo "$1 $2"
  }

  export -f packer

  run main

  assert_success
  assert_output "validate $IMAGE_DEFINITION"

}
