#!/bin/bash
set -euo pipefail

FROM_IMAGE_TAG="${1}"
TO_IMAGE_TAG="${2}"

ECR_REPO_NAME="${XTAGES_ORG}/${XTAGES_PROJECT}"

# grab the manifest of the staging image
MANIFEST=$(aws ecr batch-get-image \
  --repository-name "${ECR_REPO_NAME}" \
  --image-ids imageTag="${FROM_IMAGE_TAG}" \
  --query 'images[].imageManifest' \
  --output text)

# re-tag the staging image to prod
aws ecr put-image --repository-name "${ECR_REPO_NAME}" --image-tag "${TO_IMAGE_TAG}" --image-manifest "$MANIFEST"
