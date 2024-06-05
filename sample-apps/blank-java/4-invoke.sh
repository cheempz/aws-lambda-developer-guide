#!/bin/bash
set -eo pipefail
source ../helpers.sh
STACK=apm-bench-java
functions=$(_get_function_ids $STACK function)

while true; do
  for fn in $functions; do
    [[ "$fn" =~ skip ]] && continue
    api_path=$(echo "$fn" | grep -o 'function[^-]*')
    echo -e "\n--- $fn $api_path ---\n"
    for name in event event-exception; do
      aws lambda invoke --function-name "$fn" --payload "fileb://${name}.json" out.json
      cat out.json
      echo ""
    done
  done
done