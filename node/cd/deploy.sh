#!/bin/bash
set -euo pipefail
# this path is inferred from the buildspec file that is in S3 repo tf_live_production
# assigning variables for paths as they need to be relative to run in CodeBuild
RECIPES_BASE_PATH="$PWD"
cd ../project_src
PROJECT_PATH="$PWD"

SCRIPT_DIR=$(dirname "${0}")

# copying the Dockerfile to build the image
cp "${RECIPES_BASE_PATH}/${XTAGES_PROJECT_TYPE}/cd/Dockerfile" "${PROJECT_PATH}"

cd "${PROJECT_PATH}"

# build docker image and push it to ECR
# docker login is performed in the buildspec (S3)
IMAGE_NAME="606626603369.dkr.ecr.us-east-1.amazonaws.com/${XTAGES_PROJECT}:staging-${XTAGES_GH_PROJECT_TAG}"
docker build --build-arg NODE_VERSION="${XTAGES_NODE_VER}" --tag "${IMAGE_NAME}" .
docker push "${IMAGE_NAME}"

# deploy to ECS with Terraform
# the deploy script always targets "staging"
sh -x "${RECIPES_BASE_PATH}/${SCRIPT_DIR}"/_deploy_to_ecs.sh "${RECIPES_BASE_PATH}" "staging" "${XTAGES_GH_PROJECT_TAG}"
