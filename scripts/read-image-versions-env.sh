#!/usr/bin/env bash

ENV_FILE_PATH=image-versions.env \
OUTPUT_TEMPLATE="::set-output name=_key_::_value_" \
"$(dirname "$0")/read-env-file.sh"