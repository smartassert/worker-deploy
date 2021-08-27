#!/usr/bin/env bash

if [ -z "$OUTPUT_TEMPLATE" ]; then
  OUTPUT_TEMPLATE="_key_=_value_"
fi

while read -r line
do
  if [ "" != "$line" ]; then
    key=$(echo "$line" | cut -d'=' -f1)
    value=$(echo "$line" | cut -d'=' -f2)

    output_line="$OUTPUT_TEMPLATE"

    output_line="${output_line//_key_/$key}"
    output_line="${output_line//_value_/$value}"

    echo "$output_line"
  fi
done < "$ENV_FILE_PATH"
