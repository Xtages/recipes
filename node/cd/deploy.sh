#!/bin/bash
XTAGES_PROJECT=$1
XTAGES_APP_ENV=$2
NODE_VERSION=$3
# this path is inferred from the buildspec file that is in S3 repo tf_live_production
PROJECT_PATH=../../../project_src
cp Dockerfile $PROJECT_PATH
cd $PROJECT_PATH || exit
DATE=$(date '+%Y%m%d%H%M')
GIT_HASH=$(git rev-parse --short HEAD)
TAG=$DATE-$GIT_HASH

# build docker image and push it to ECR
# docker login is performed in the buildspec (S3)
docker build --build-arg NODE_VERSION="${NODE_VERSION}" \
-t 606626603369.dkr.ecr.us-east-1.amazonaws.com/"${XTAGES_ORG}"/"${XTAGES_PROJECT}-${XTAGES_APP_ENV}:$TAG" .
docker push 606626603369.dkr.ecr.us-east-1.amazonaws.com/"${XTAGES_ORG}"/"${XTAGES_PROJECT}-${XTAGES_APP_ENV}:$TAG"

# deploy to ECS with Terraform
(cd -) && (cd terraform || exit)
export TF_VAR_TAG=$TAG
export TF_VAR_APP_NAME="${XTAGES_PROJECT}"
export TF_VAR_APP_ENV="${XTAGES_APP_ENV}"
export TF_VAR_ORG="${XTAGES_ORG}"
# This is a workaround to use variables in the Terraform state file
# https://github.com/hashicorp/terraform/issues/13022#issuecomment-294262392
terraform init \
  -backend-config "key=${TF_VAR_APP_NAME}"
terraform plan && terraform apply -auto-approve
