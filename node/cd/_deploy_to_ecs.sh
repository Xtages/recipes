#!/bin/bash
set -euo pipefail

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

cd "${RECIPES_BASE_PATH}"/terraform
# This is a workaround to use variables in the Terraform state file
# https://github.com/hashicorp/terraform/issues/13022#issuecomment-294262392
terraform init \
  -backend-config "key=tfstate/us-east-1/production/${TF_VAR_APP_ORG_HASH}/${TF_VAR_APP_ENV}/app/${TF_VAR_APP_NAME_HASH}"
terraform plan && terraform apply -auto-approve
