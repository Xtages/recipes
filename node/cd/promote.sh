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

# re-tag the staging image to prod
sh -x "${SCRIPTS_PATH}"/_re_tag_image.sh "${STAGING_IMAGE_TAG}" "${PRODUCTION_IMAGE_TAG}"

# deploy to ECS with Terraform
# the promote script always targets "production"
sh -x "${SCRIPTS_PATH}"/_deploy_to_ecs.sh "${RECIPES_BASE_PATH}" "production" "${XTAGES_GH_PROJECT_TAG}"
sh -x "${SCRIPTS_PATH}"/upload_logs.sh
