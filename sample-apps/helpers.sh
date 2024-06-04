#!/bin/bash

_get_function_id() {
    aws cloudformation describe-stack-resource --stack-name "$1" \
        --logical-resource-id "$2" \
        --query 'StackResourceDetail.PhysicalResourceId' \
        --output text
}

_get_function_ids() {
    # shellcheck disable=SC2016
    aws cloudformation list-stack-resources --stack-name "$1" \
        --query '*[?ResourceType==`AWS::Lambda::Function`].PhysicalResourceId' \
        --output text
}

_get_api_id() {
    aws cloudformation describe-stack-resource --stack-name "$1" \
        --logical-resource-id "$2" \
        --query 'StackResourceDetail.PhysicalResourceId' \
        --output text
}