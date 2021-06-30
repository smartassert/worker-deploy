#!/usr/bin/env bash

echo "pre cat"
cat local.image-versions.env
echo "post cat"

while read line
do
  key=$(echo $line | cut -d'=' -f1)
  value=$(echo $line | cut -d'=' -f2)
  echo "::set-output name=$key::$value"
done < local.image-versions.env
