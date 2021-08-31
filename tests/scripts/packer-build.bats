#!/usr/bin/env bats

setup() {
  load 'node_modules/bats-support/load'
  load 'node_modules/bats-assert/load'
  load 'node_modules/bats-file/load'

  export IMAGE_DEFINITION="image.pkr.hcl"
  export PACKER_LOG_PATH="$BATS_TMPDIR/packer.log"
  export IMAGE_ID_PATH="$BATS_TMPDIR/image_id"
  export EXPECTED_PACKER_ARGUMENTS="build $IMAGE_DEFINITION"

  teardown
}

teardown() {
  rm -f "$PACKER_LOG_PATH"
  rm -f "$IMAGE_ID_PATH"
}

main() {
  bash "${BATS_TEST_DIRNAME}"/../../scripts/packer-build.sh
}

@test "packer build call fails if last line of output does not contain image ID" {
  function packer() {
    echo "$1 $2"
  }

  export -f packer

  run main

  assert_failure
  assert_line --index 0 "$EXPECTED_PACKER_ARGUMENTS"

}

@test "packer build call is successful" {
  IMAGE_ID="90571431"

  PACKER_OUTPUT=$(
    echo "digitalocean.worker: output will be in this color."
    echo "..."
    echo "--> digitalocean.worker: A snapshot was created: 'snapshot-name' (ID: $IMAGE_ID) in regions 'lon1'"
  )
  export PACKER_OUTPUT

  EXPECTED_PACKER_LOG_FILE_SIZE="${#PACKER_OUTPUT}"
  EXPECTED_PACKER_LOG_FILE_SIZE=$((EXPECTED_PACKER_LOG_FILE_SIZE+1))

  function packer() {
    echo "$1 $2"
    echo "$PACKER_OUTPUT"
  }

  export -f packer

  run main

  TRIMMED_PACKER_OUTPUT=$(cat "$PACKER_LOG_PATH" | tail -3)

  assert_success
  assert_line --index 0 "$EXPECTED_PACKER_ARGUMENTS"
  assert_file_exist "$PACKER_LOG_PATH"
  assert_file_exist "$IMAGE_ID_PATH"
  assert_file_contains "$IMAGE_ID_PATH" "$IMAGE_ID"
  assert_equal "$TRIMMED_PACKER_OUTPUT" "$PACKER_OUTPUT"
}
