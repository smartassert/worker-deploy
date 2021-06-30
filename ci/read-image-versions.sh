#!/usr/bin/env bash

ls -la
cat local.image-versions.env

while read line
do
  key=$(echo $line | cut -d'=' -f1)
  value=$(echo $line | cut -d'=' -f2)
  echo "::set-output name=$key::$value"
done < local.image-versions.env
