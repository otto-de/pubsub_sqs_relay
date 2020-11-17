#! /usr/bin/env bash

set -eo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" ; pwd -P)"
. "${SCRIPT_DIR}/helper.inc.sh"

if [[ $# -lt 2 ]]; then
    echo "usage: ${0} <deployment> <environment> [extra-tf-args...]"
    echo "        deployment:    dir in /terraform"
    echo "        environment:   nonlive, live, infrastructure or similar"
    echo "        extra-tf-args: something like '-var version=foo'"
    exit 1
fi

deployTf "${@}"