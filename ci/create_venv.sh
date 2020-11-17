#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" ; pwd -P)"
VENV_DIR="${SCRIPT_DIR}/../venv"

virtualenv "${VENV_DIR}"
. "${VENV_DIR}/bin/activate"
pip3 install -r src/requirements.txt

. "./venv/bin/activate"