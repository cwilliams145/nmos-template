#!/bin/bash

set -o errexit

rm -rf .scripts
git clone https://${GITHUB_TOKEN:+${GITHUB_TOKEN}@}github.com/AMWA-TV/nmos-doc-build-scripts .scripts
.scripts/install-dependencies.sh
