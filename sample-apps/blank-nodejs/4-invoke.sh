#!/bin/bash
set -eo pipefail
source ../helpers.sh
STACK=apm-bench-nodejs
functions=$(_get_function_ids $STACK function)
api_id=$(_get_api_id $STACK api)
api_endpoint=https://${api_id}.execute-api.us-east-1.amazonaws.com/api

while true; do
  for fn in $functions; do
    [[ "$fn" =~ skip ]] && continue
    api_path=$(echo "$fn" | grep -o 'function[^-]*')
    echo -e "\n--- $fn $api_path ---\n"
    for name in event event-exception event-rpc; do
      aws lambda invoke --function-name "$fn" --payload "fileb://${name}.json" out.json
      cat out.json
      echo ""
    done
    curl -i "$api_endpoint"/"$api_path"
  done
done