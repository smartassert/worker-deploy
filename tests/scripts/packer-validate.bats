#!/usr/bin/env bats

script_name=$(basename "$BATS_TEST_FILENAME" | sed 's/bats/sh/g')
export script_name

setup() {
  load 'node_modules/bats-assert/load'

  export IMAGE_DEFINITION="image.pkr.hcl"
}

main() {
  bash "${BATS_TEST_DIRNAME}/../../scripts/$script_name"
}

@test "$script_name: call is formed successfully" {
  function packer() {
    echo "$1 $2"
  }

  export -f packer

  run main

  assert_success
  assert_output "validate $IMAGE_DEFINITION"

}
