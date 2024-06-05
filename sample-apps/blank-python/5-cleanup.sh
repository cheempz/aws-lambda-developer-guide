#!/bin/bash
set -eo pipefail
source ../helpers.sh
STACK=lin-test-blank-python
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

rm -f out.yml out.json function/*.pyc
rm -rf package function/__pycache__
