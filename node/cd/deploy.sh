#!/bin/bash
XTAGES_APP_ENV=$1
NODE_VERSION=$2
XTAGES_ORG=$3
APP_TAG=$4
# this path is inferred from the buildspec file that is in S3 repo tf_live_production
PROJECT_PATH=../../../project_src
cp Dockerfile $PROJECT_PATH
cd $PROJECT_PATH || exit
#TAG=$(date -u '+%Y%m%d%H%M')-$(git rev-parse --short HEAD)
XTAGES_PROJECT=$(basename -s .git "$(git config --get remote.origin.url)")

# build docker image and push it to ECR
# docker login is performed in the buildspec (S3)
docker build --build-arg NODE_VERSION="${NODE_VERSION}" \
--tag 606626603369.dkr.ecr.us-east-1.amazonaws.com/"${XTAGES_ORG}"/"${XTAGES_PROJECT}-${XTAGES_APP_ENV}:${APP_TAG}" .
docker push 606626603369.dkr.ecr.us-east-1.amazonaws.com/"${XTAGES_ORG}"/"${XTAGES_PROJECT}-${XTAGES_APP_ENV}:${APP_TAG}"

# deploy to ECS with Terraform
(cd -) && (cd ../../terraform || exit)
export TF_VAR_TAG=$APP_TAG
export TF_VAR_APP_NAME="${XTAGES_PROJECT}"
export TF_VAR_APP_ENV="${XTAGES_APP_ENV}"
export TF_VAR_APP_ORG="${XTAGES_ORG}"
# This is a workaround to use variables in the Terraform state file
# https://github.com/hashicorp/terraform/issues/13022#issuecomment-294262392
terraform init \
  -backend-config "key=tfstate/us-east-1/production/${TF_VAR_APP_ORG}/${TF_VAR_APP_NAME}/app/${TF_VAR_APP_ENV}"
terraform plan && terraform apply -auto-approve
