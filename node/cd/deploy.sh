#!/bin/bash
set -euo pipefail
PROJECT_TYPE=$1
XTAGES_APP_ENV=$2
NODE_VERSION=$3
XTAGES_ORG=$4
APP_TAG=$5
# this path is inferred from the buildspec file that is in S3 repo tf_live_production
RECIPES_BASE_PATH="$PWD"
cd ../project_src
PROJECT_PATH="$PWD"

cd "${RECIPES_BASE_PATH}/${PROJECT_TYPE}/cd"
cp Dockerfile "${PROJECT_PATH}"

cd "${PROJECT_PATH}"
XTAGES_PROJECT="$(basename -s .git "$(git config --get remote.origin.url)")"
XTAGES_PROJECT=$(echo "${XTAGES_PROJECT}" | tr '[:upper:]' '[:lower:]')

# Terraform ECR repo creation if needed
cd "${RECIPES_BASE_PATH}"/terraform/ecr
export TF_VAR_TAG="${APP_TAG}"
export TF_VAR_APP_NAME="${XTAGES_PROJECT}"
export TF_VAR_APP_ENV="${XTAGES_APP_ENV}"
export TF_VAR_APP_ORG="${XTAGES_ORG}"

terraform init \
  -backend-config "key=tfstate/us-east-1/production/${TF_VAR_APP_ORG}/${TF_VAR_APP_ENV}/app/${TF_VAR_APP_NAME}"
terraform plan && terraform apply -auto-approve

cd "${PROJECT_PATH}"
# build docker image and push it to ECR
# docker login is performed in the buildspec (S3)
docker build --build-arg NODE_VERSION="${NODE_VERSION}" \
  --tag 606626603369.dkr.ecr.us-east-1.amazonaws.com/"${XTAGES_ORG}/${XTAGES_PROJECT}-${XTAGES_APP_ENV}:${APP_TAG}" .
docker push 606626603369.dkr.ecr.us-east-1.amazonaws.com/"${XTAGES_ORG}/${XTAGES_PROJECT}-${XTAGES_APP_ENV}:${APP_TAG}"

# deploy to ECS with Terraform
cd "${RECIPES_BASE_PATH}"/terraform
# This is a workaround to use variables in the Terraform state file
# https://github.com/hashicorp/terraform/issues/13022#issuecomment-294262392
terraform init \
  -backend-config "key=tfstate/us-east-1/production/${TF_VAR_APP_ORG}/${TF_VAR_APP_ENV}/app/${TF_VAR_APP_NAME}"
terraform plan && terraform apply -auto-approve
