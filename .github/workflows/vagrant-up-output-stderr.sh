#!/usr/bin/env bash

OUTPUT="$(vagrant up --no-color basil_worker 2>$STDERR_FILE)"
exit 0
