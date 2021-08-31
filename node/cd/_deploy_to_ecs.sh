#!/bin/bash
set -euo pipefail

declare -A buckets
export buckets=(["production"]="xtages-tfstate-customers" ["development"]="xtages-tfstate-customers-development")

SCRIPT_DIR=$(dirname "${0}")
RECIPES_BASE_PATH="${1}"
APP_ENV="${2}"
SHORT_COMMIT="${3}"

# deploy to ECS with Terraform
# env variables used by Terraform
export TF_VAR_TAG="${SHORT_COMMIT}"
export TF_VAR_APP_NAME_HASH="${XTAGES_PROJECT}"
export TF_VAR_APP_ENV="${APP_ENV}"
export TF_VAR_APP_ORG="${XTAGES_ORG}"
export TF_VAR_APP_ORG_HASH="${XTAGES_ORG_HASH}"
export TF_VAR_HOST_HEADER="${XTAGES_HOST_HEADER}"
export TF_VAR_CUSTOMER_DOMAIN="${XTAGES_CUSTOMER_DOMAIN}"
export TF_VAR_APP_BUILD_ID="${XTAGES_BUILD_ID}"
export TF_VAR_ENV="${XTAGES_ENV}"
export TF_VAR_BACKEND_BUCKET="${buckets[${XTAGES_ENV}]}"

cd "${RECIPES_BASE_PATH}"/terraform
#sh "${SCRIPT_DIR}"/metrics.sh "terraform" "0" "command=init"
# This is a workaround to use variables in the Terraform state file
# https://github.com/hashicorp/terraform/issues/13022#issuecomment-294262392
terraform init -no-color \
  -backend-config "bucket=${TF_VAR_BACKEND_BUCKET}" \
  -backend-config "key=tfstate/us-east-1/${TF_VAR_ENV}/${TF_VAR_APP_ORG_HASH}/${TF_VAR_APP_ENV}/app/${TF_VAR_APP_NAME_HASH}" \
   > "${SCRIPT_DIR}"/terraform.log 2>&1
#  || sh "${SCRIPT_DIR}"/metrics.sh "terraform" "1" "command=init"

#sh "${SCRIPT_DIR}"/metrics.sh "terraform" "0" "command=plan"
terraform plan -no-color >> "${SCRIPT_DIR}"/terraform.log 2>&1
#  || sh "${SCRIPT_DIR}"/metrics.sh "terraform" "1" "command=plan"

#sh "${SCRIPT_DIR}"/metrics.sh "terraform" "0" "command=apply"
terraform apply -auto-approve -no-color >> "${SCRIPT_DIR}"/terraform.log 2>&1
#  || sh "${SCRIPT_DIR}"/metrics.sh "terraform" "1" "command=apply"
