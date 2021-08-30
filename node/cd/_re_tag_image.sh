#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(dirname "${0}")
FROM_IMAGE_TAG="${1}"
TO_IMAGE_TAG="${2}"
SCRIPTS_PATH="${PWD}/${SCRIPT_DIR}"

ECR_REPO_NAME="${XTAGES_PROJECT}"

# grab the manifest of the staging image
sh -x "${SCRIPTS_PATH}"/metrics.sh "ecr" "1" "batch-get-image=start"
MANIFEST=$(aws ecr batch-get-image \
  --repository-name "${ECR_REPO_NAME}" \
  --image-ids imageTag="${FROM_IMAGE_TAG}" \
  --query 'images[].imageManifest' \
  --output text > ecr.log)
sh -x "${SCRIPTS_PATH}"/metrics.sh "ecr" "1" "batch-get-image=finish"

sh -x "${SCRIPTS_PATH}"/metrics.sh "ecr" "1" "put-image=start"
# re-tag the staging image to prod
aws ecr put-image --repository-name "${ECR_REPO_NAME}" --image-tag "${TO_IMAGE_TAG}" --image-manifest "$MANIFEST" >> ecr.log
sh -x "${SCRIPTS_PATH}"/metrics.sh "ecr" "1" "put-image=finish"
