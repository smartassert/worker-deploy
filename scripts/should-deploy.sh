#!/usr/bin/env bash

[ "$EVENT_NAME" = "release" ] || [ "$INPUT_SHOULD_DEPLOY" = "true" ] && echo "true" || echo "false"
