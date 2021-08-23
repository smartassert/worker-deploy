#!/usr/bin/env bash

rm -f "$RELEASE_NOTES_PATH"

{
  echo "- compiler: $COMPILER_VERSION"
  echo "- chrome runner: $CHROME_RUNNER_VERSION"
  echo "- firefox runner: $FIREFOX_RUNNER_VERSION"
  echo "- delegator: $DELEGATOR_VERSION"
  echo "- worker: $WORKER_VERSION"
} >> "$RELEASE_NOTES_PATH"
