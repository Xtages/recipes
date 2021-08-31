#!/bin/bash
set -euo pipefail

declare -A environments
export environments=(["production"]="606626603369" ["development"]="605769209612")

# this path is inferred from the buildspec file that is in S3 repo tf_live_production
# assigning variables for paths as they need to be relative to run in CodeBuild
RECIPES_BASE_PATH="$PWD"
cd ../project_src
PROJECT_PATH="$PWD"
AWS_ACCOUNT_ID=${environments[${XTAGES_ENV}]}
SCRIPT_DIR=$(dirname "${0}")
# path for scripts
SCRIPTS_PATH="${RECIPES_BASE_PATH}/${SCRIPT_DIR}"

send_logs() {
  sh "${SCRIPTS_PATH}"/upload_logs.sh "${SCRIPTS_PATH}" "$1"
}

# copying the Dockerfile to build the image
cp "${RECIPES_BASE_PATH}/${XTAGES_PROJECT_TYPE}/cd/Dockerfile" "${PROJECT_PATH}"
cd "${PROJECT_PATH}"

# same idea than here: https://medium.com/@dirk.avery/the-bash-trap-trap-ce6083f36700
trap 'send_logs $?' EXIT

# build docker image and push it to ECR
# docker login is performed in the buildspec (S3)
sh "${SCRIPTS_PATH}"/metrics.sh "docker" "0" "command=build"
IMAGE_NAME="${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/${XTAGES_PROJECT}:staging-${XTAGES_GH_PROJECT_TAG}"
echo "########### Building Application Code ###########"
docker build --build-arg AWS_ACCOUNT="${AWS_ACCOUNT_ID}" \
  --build-arg NODE_VERSION="${XTAGES_NODE_VER}" \
  --build-arg DB_URL="${XTAGES_DB_URL}" \
  --build-arg DB_USER="${XTAGES_DB_USER}" \
  --build-arg DB_NAME="${XTAGES_DB_NAME}" \
  --build-arg DB_PASS="${XTAGES_DB_PASS}"  \
  --tag "${IMAGE_NAME}" . 2>&1 | tee "${SCRIPTS_PATH}"/docker.log \
  || sh "${SCRIPTS_PATH}"/metrics.sh "docker" "1" "command=build,status=$?"

echo "########### Uploading Image to Xtages Registry ###########"
sh "${SCRIPTS_PATH}"/metrics.sh "docker" "0" "command=push"
docker push "${IMAGE_NAME}" >> "${SCRIPTS_PATH}"/docker.log 2>&1 \
  || sh "${SCRIPTS_PATH}"/metrics.sh "docker" "1" "command=push,status=$?"


echo "########### Deploying to Xtages Platform ###########"
# deploy to ECS with Terraform
# the deploy script always targets "staging"
sh "${SCRIPTS_PATH}"/_deploy_to_ecs.sh "${RECIPES_BASE_PATH}" "staging" "${XTAGES_GH_PROJECT_TAG}"
