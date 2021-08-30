#!/bin/bash
set -euo pipefail
# this path is inferred from the buildspec file that is in S3 repo tf_live_production
# assigning variables for paths as they need to be relative to run in CodeBuild
RECIPES_BASE_PATH="$PWD"
SCRIPT_DIR=$(dirname "${0}")
# path for scripts
SCRIPTS_PATH="${RECIPES_BASE_PATH}/${SCRIPT_DIR}"

trap 'send_logs $?' EXIT

# deploy to ECS with Terraform
sh -x "${SCRIPTS_PATH}"/_deploy_to_ecs.sh "${RECIPES_BASE_PATH}" "production" "${XTAGES_PREVIOUS_GH_PROJECT_TAG}"

send_logs() {
  sh -x "${SCRIPTS_PATH}"/upload_logs.sh "$1"
}
