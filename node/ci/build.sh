#!/bin/bash
set -euo pipefail
cd ../project_src
npm install
npm run build
npm test
