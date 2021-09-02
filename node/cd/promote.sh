#!/bin/bash
set -euo pipefail
# this path is inferred from the buildspec file that is in S3 repo tf_live_production
# assigning variables for paths as they need to be relative to run in CodeBuild
RECIPES_BASE_PATH="$PWD"
SCRIPT_DIR=$(dirname "${0}")
# path for scripts
SCRIPTS_PATH="${RECIPES_BASE_PATH}/${SCRIPT_DIR}"

STAGING_IMAGE_TAG="staging-${XTAGES_GH_PROJECT_TAG}"
PRODUCTION_IMAGE_TAG="production-${XTAGES_GH_PROJECT_TAG}"

check_prod_ecr_img() {
  aws ecr describe-images --repository-name "${XTAGES_PROJECT}" --image-ids imageTag="${PRODUCTION_IMAGE_TAG}" > /dev/null 2>&1
}

send_logs() {
  sh "${SCRIPTS_PATH}"/upload_logs.sh "${SCRIPTS_PATH}" "$1"
}
trap 'send_logs $?' EXIT

# check if the prod image already exist
echo "########### Preparing application for Production ###########"
if ! check_prod_ecr_img; then
  # re-tag the staging image to prod
  sh "${SCRIPTS_PATH}"/_re_tag_image.sh "${STAGING_IMAGE_TAG}" "${PRODUCTION_IMAGE_TAG}"
fi

echo "########### Deploying to Xtages Cloud ###########"
# deploy to ECS with Terraform
# the promote script always targets "production"
sh "${SCRIPTS_PATH}"/_deploy_to_ecs.sh "${RECIPES_BASE_PATH}" "production" "${XTAGES_GH_PROJECT_TAG}"
