#!/bin/bash
set -euo pipefail
XTAGES_APP_ENV=$2
XTAGES_ORG=$4
APP_TAG=$5


export TF_VAR_TAG="${APP_TAG}"
export TF_VAR_APP_NAME="${XTAGES_PROJECT}"
export TF_VAR_APP_ENV="${XTAGES_APP_ENV}"
export TF_VAR_APP_ORG="${XTAGES_ORG}"

terraform init \
  -backend-config "key=tfstate/us-east-1/production/${TF_VAR_APP_ORG}/${TF_VAR_APP_ENV}/app/${TF_VAR_APP_NAME}"
terraform destroy -auto-approve
