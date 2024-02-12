#!/bin/bash
set -eo pipefail
STACK=lin-test-blank-java
FUNCTION1=$(aws cloudformation describe-stack-resource --stack-name $STACK --logical-resource-id function1 --query 'StackResourceDetail.PhysicalResourceId' --output text)
FUNCTION2=$(aws cloudformation describe-stack-resource --stack-name $STACK --logical-resource-id function2 --query 'StackResourceDetail.PhysicalResourceId' --output text)

while true; do
  for name in event-randsleep event-exception; do
    aws lambda invoke --function-name $FUNCTION1 --payload "fileb://${name}.json" out.json
    cat out.json
    echo ""
  done
  for name in event; do
    aws lambda invoke --function-name $FUNCTION2 --payload "fileb://${name}.json" out.json
    cat out.json
    echo ""
  done
done