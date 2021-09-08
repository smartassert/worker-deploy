#!/usr/bin/env bats

script_name=$(basename "$BATS_TEST_FILENAME" | sed 's/bats/sh/g')
export script_name

setup() {
  load 'node_modules/bats-support/load'
  load 'node_modules/bats-assert/load'
  load 'node_modules/bats-file/load'

  export PACKER_LOG_PATH="$BATS_TMPDIR/packer.log"

  teardown
}

teardown() {
  rm -f "$PACKER_LOG_PATH"
}

main() {
  bash "${BATS_TEST_DIRNAME}/../../scripts/$script_name"
}

@test "$script_name: packer log path not set" {
  unset PACKER_LOG_PATH
  run main

  assert_failure "3"
  assert_output ""
}

@test "$script_name: packer log path not found" {
  run main

  assert_failure "4"
  assert_output ""
}

@test "$script_name: no line containing 'Snapshot image ID' present" {
  echo "non-empty content" > "$PACKER_LOG_PATH"

  run main

  assert_failure "1"
  assert_output ""
}

@test "$script_name: success" {
  echo "2021/09/08 08:46:05 ui: digitalocean.worker_base: output will be in this color.
2021/09/08 08:48:21 Starting build run: digitalocean.worker_base
...
2021/09/08 08:52:49 packer-builder-digitalocean plugin: Snapshot image ID: 91393692
...
" > "$PACKER_LOG_PATH"

  run main

  assert_success
  assert_output "91393692"
}
