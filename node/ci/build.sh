#!/bin/bash
# variable set in the buildspec (S3) to clone this repo.
export XTAGES_RECIPE_GIT_TOKEN=""

set -euo pipefail
cd ../project_src
npm install
npm run build
npm test
