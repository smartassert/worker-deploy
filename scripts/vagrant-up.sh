#!/usr/bin/env bash

set +e

vagrant up --no-color basil_worker 2>"$STDERR_FILE"
exit 0
