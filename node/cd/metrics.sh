#!/bin/bash

METRIC_NAME=$1
NAMESPACE="xtages-infra"
VALUE=$2
ADDITIONAL_DIMENSION=$3
# magic to assign 0 as default variable if $4 doesn't have a value
STATUS=$4
EXIT_CODE="${STATUS:=0}"
DIMENSIONS="organization=${XTAGES_ORG_HASH},project=${XTAGES_PROJECT},environment=${XTAGES_APP_ENV},${ADDITIONAL_DIMENSION}"

#  aws cloudwatch put-metric-data --metric-name Buffers --namespace MyNameSpace --unit Bytes --value 231434333 --dimensions InstanceID=1-23456789,InstanceType=m1.small
aws cloudwatch put-metric-data --namespace "${NAMESPACE}" \
--metric-name "${METRIC_NAME}" \
--value "${VALUE}" \
--dimensions "${DIMENSIONS}"

exit "${EXIT_CODE}"
