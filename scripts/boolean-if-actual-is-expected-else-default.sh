#!/usr/bin/env bash

[ "$ACTUAL" = "$EXPECTED" ] || [ "$DEFAULT" = "true" ] && echo "true" || echo "false"
