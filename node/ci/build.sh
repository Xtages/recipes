#!/bin/bash
# variable set in the buildspec (S3) to clone this repo.
export XTAGES_RECIPE_GIT_TOKEN=""

set -euo pipefail
cd ../project_src
NPM_OPTIONS=--no-color

npm "${NPM_OPTIONS}" install
npm "${NPM_OPTIONS}" run build
npm "${NPM_OPTIONS}" test
