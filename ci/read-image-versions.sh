#!/usr/bin/env bash

while read line
do
  key=$(echo $line | cut -d'=' -f1)
  value=$(echo $line | cut -d'=' -f2)
  echo "::set-output name=$key::$value"
done < local.image-versions.env
