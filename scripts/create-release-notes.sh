#!/usr/bin/env bash

rm -f $RELEASE_NOTES_PATH
echo "- compiler: $COMPILER_VERSION" >> $RELEASE_NOTES_PATH
echo "- chrome runner: $CHROME_RUNNER_VERSION" >> $RELEASE_NOTES_PATH
echo "- firefox runner: $FIREFOX_RUNNER_VERSION" >> $RELEASE_NOTES_PATH
echo "- delegator: $DELEGATOR_VERSION" >> $RELEASE_NOTES_PATH
echo "- worker: $WORKER_VERSION" >> $RELEASE_NOTES_PATH
