#!/bin/bash

METRIC_NAME=$1
NAMESPACE="xtages-infra"
VALUE=$2
DIMENSIONS="organization=${XTAGES_ORG_HASH},project=${XTAGES_PROJECT},environment=${XTAGES_APP_ENV}"

#  aws cloudwatch put-metric-data --metric-name Buffers --namespace MyNameSpace --unit Bytes --value 231434333 --dimensions InstanceID=1-23456789,InstanceType=m1.small
aws cloudwatch put-metric-data --namespace "${NAMESPACE}" \
--metric-name "${METRIC_NAME}" \
--value "${VALUE}" \
--dimensions "${DIMENSIONS}"
