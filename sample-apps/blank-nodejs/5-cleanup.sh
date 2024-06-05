#!/bin/bash
set -eo pipefail
source ../helpers.sh
STACK=apm-bench-nodejs
if [[ $# -eq 1 ]] ; then
    STACK=$1
    echo "Deleting stack $STACK"
fi
functions=$(_get_function_ids $STACK);
echo "Functions: $functions"
aws cloudformation delete-stack --stack-name $STACK
echo "Deleted $STACK stack."

_delete_bucket
_delete_logs "$functions"

rm -f out.yml out.json
rm -rf lib package-lock.json
