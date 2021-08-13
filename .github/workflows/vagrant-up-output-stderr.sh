#!/usr/bin/env bash

VAGRANT_ERROR_OUTPUT="$(vagrant up basil_worker 2>&1 > /dev/null)"
echo "$VAGRANT_ERROR_OUTPUT"
