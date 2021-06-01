#!/bin/bash
set -euo pipefail
cd /project_src || exit
npm install
npm run build
npm test
