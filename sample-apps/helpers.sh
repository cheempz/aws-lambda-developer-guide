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

_delete_bucket() {
    if [ -f bucket-name.txt ]; then
        ARTIFACT_BUCKET=$(cat bucket-name.txt)
        if [[ ! $ARTIFACT_BUCKET =~ apm-bench-.*-lambda-artifacts ]] ; then
            echo "Bucket was not created by this application. Skipping."
        else
            while true; do
                read -rp "Delete deployment artifacts and bucket ($ARTIFACT_BUCKET)? (y/n)" response
                case $response in
                    [Yy]* ) aws s3 rb --force s3://"$ARTIFACT_BUCKET"; rm bucket-name.txt; break;;
                    [Nn]* ) break;;
                    * ) echo "Response must start with y or n.";;
                esac
            done
        fi
    fi
}

_delete_logs() {
    for fn in $1; do
        while true; do
            read -rp "Delete function log group (/aws/lambda/$fn)? (y/n)" response
            case $response in
                [Yy]* ) aws logs delete-log-group --log-group-name /aws/lambda/"$fn" || true; break;;
                [Nn]* ) break;;
                * ) echo "Response must start with y or n.";;
            esac
        done
    done
}