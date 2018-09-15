#!/usr/bin/env bash

# -e: exit as soon as a command exit with a non-zero status code
# -u: prevent from any undefined variable
# -o pipefail: force pipelines to fail on the first non-zero status code
set -euo pipefail
# Avoid using space as a separator (default IFS=$' \t\n')
IFS=$'\n\t'

DOCKER_ORGANIZATION=juliendufresne

for dockerfile in $(find * -mindepth 2 -maxdepth 2 -name "Dockerfile"); do
    IFS="/" read -ra DOCKER_PARAMS <<< "$dockerfile"
    (set -x; ./test.sh $DOCKER_ORGANIZATION "${DOCKER_PARAMS[0]}" "${DOCKER_PARAMS[1]}")
done
