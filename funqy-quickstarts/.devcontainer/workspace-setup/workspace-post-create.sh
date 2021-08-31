#!/bin/bash

set -euo pipefail

WORKSPACE_FOLDER=${1}

rsync -a .devcontainer/workspace-setup/ ${WORKSPACE_FOLDER}/.vscode/ --ignore-existing

#sudo pip install -r requirements.txt