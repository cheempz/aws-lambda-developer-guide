#!/bin/bash
set -eo pipefail
STACK=lin-test-blank-java
FUNCTION=$(aws cloudformation describe-stack-resource --stack-name $STACK --logical-resource-id function --query 'StackResourceDetail.PhysicalResourceId' --output text)

while true; do
  for name in event event-exception; do
    aws lambda invoke --function-name $FUNCTION --payload "fileb://${name}.json" out.json
    cat out.json
    echo ""
  done
done