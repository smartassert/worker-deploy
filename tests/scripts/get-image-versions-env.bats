#!/usr/bin/env bats

script_name=$(basename "$BATS_TEST_FILENAME" | sed 's/bats/sh/g')
export script_name

setup() {
  load 'node_modules/bats-assert/load'
  load 'node_modules/bats-file/load'

  export VERSION="0.5"
  export ENV_FILE_PATH="$BATS_TMPDIR/tmp-env-file.env"

  export ENV_FILE_CONTENT="COMPILER_VERSION=0.1
CHROME_RUNNER_VERSION=0.2
FIREFOX_RUNNER_VERSION=0.3
DELEGATOR_VERSION=0.4
WORKER_VERSION=0.5"

  EXPECTED_FILE_SIZE="${#ENV_FILE_CONTENT}"
  EXPECTED_FILE_SIZE=$((EXPECTED_FILE_SIZE+1))
  export EXPECTED_FILE_SIZE

  rm -f "$ENV_FILE_PATH"

  function curl() {
    if [ "$5" != "" ]; then
      echo "200"
    else
      echo "$ENV_FILE_CONTENT"
    fi
  }

  export -f curl
}

teardown() {
  rm -f "$ENV_FILE_PATH"
}

main() {
  bash "${BATS_TEST_DIRNAME}/../../scripts/$script_name"
}

@test "$script_name: request is successful" {
  assert_file_not_exist "$ENV_FILE_PATH"

  run main

  assert_success
  assert_file_exist "$ENV_FILE_PATH"
  assert_file_size_equals "$ENV_FILE_PATH" "$EXPECTED_FILE_SIZE"

  LINE_INDEX=0
  for EXPECTED_LINE in $ENV_FILE_CONTENT; do
    LINE_INDEX=$((LINE_INDEX+1))
    ACTUAL_LINE=$(sed "${LINE_INDEX}q;d" "$ENV_FILE_PATH")
    assert_equal "$ACTUAL_LINE" "$EXPECTED_LINE"
  done
}
