#!/usr/bin/env bash

if [ "$VALUE1" != "" ]; then
  echo "$VALUE1"
elif [ "$VALUE2" != "" ]; then
  echo "$VALUE2"
else
  echo "$DEFAULT"
fi
