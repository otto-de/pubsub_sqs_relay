#!/usr/bin/env bash

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" ; pwd -P)"
. "${SCRIPT_DIR}/helper.inc.sh"

#TMP_DIR=$(mktemp -d)
OUTPUT="${SCRIPT_DIR}/../package.zip"
VENV_DIR="venv"
VERSION=${VERSION:-$(date +%s)}

pushd "${SCRIPT_DIR}/.." > /dev/null
  virtualenv "${VENV_DIR}"
  . "${VENV_DIR}/bin/activate"
  pip3 install -r src/requirements.txt

  echo "running unit tests"
  pushd "test"
  nosetests
  popd > /dev/null

  deactivate

  cd ${VENV_DIR}/lib/*/site-packages
    zip -rqq "${OUTPUT}" *
  cd -
  zip -urqq "${OUTPUT}" src
popd > /dev/null