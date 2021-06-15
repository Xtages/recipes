#!/bin/bash
set -euo pipefail
# this path is inferred from the buildspec file that is in S3 repo tf_live_production
# assigning variables for paths as they need to be relative to run in CodeBuild
RECIPES_BASE_PATH="$PWD"

SCRIPT_DIR=$(dirname "${0}")

#PREVIOUS_PRODUCTION_IMAGE_TAG="production-${XTAGES_PREVIOUS_GH_PROJECT_TAG}"
#PRODUCTION_IMAGE_TAG="production-${XTAGES_GH_PROJECT_TAG}"

# re-tag the staging image to prod
#sh -x "${RECIPES_BASE_PATH}/${SCRIPT_DIR}"/_re_tag_image.sh "${PREVIOUS_PRODUCTION_IMAGE_TAG}" "${PRODUCTION_IMAGE_TAG}"

# deploy to ECS with Terraform
sh -x "${RECIPES_BASE_PATH}/${SCRIPT_DIR}"/_deploy_to_ecs.sh "${RECIPES_BASE_PATH}" "production" "${XTAGES_PREVIOUS_GH_PROJECT_TAG}"
