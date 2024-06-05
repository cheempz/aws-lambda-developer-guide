#!/bin/bash
set -eo pipefail
STACK=apm-bench-ruby
ARTIFACT_BUCKET=$(cat bucket-name.txt)
PARAM_FILE="file://../swo-resources/parameters-${PARAM:-prod}.json"

rm -f function/collector-*.yaml && cp ../swo-resources/collector-*.yaml function/
aws cloudformation package --template-file template.yml --s3-bucket $ARTIFACT_BUCKET --output-template-file out.yml
aws cloudformation deploy --template-file out.yml --stack-name $STACK --capabilities CAPABILITY_NAMED_IAM --parameter-overrides $PARAM_FILE
