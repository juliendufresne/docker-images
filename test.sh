#!/usr/bin/env bash

# -e: exit as soon as a command exit with a non-zero status code
# -u: prevent from any undefined variable
# -o pipefail: force pipelines to fail on the first non-zero status code
set -euo pipefail
# Avoid using space as a separator (default IFS=$' \t\n')
IFS=$'\n\t'


DOCKER_ORGANIZATION=$1
DOCKER_IMAGE=$2
DOCKER_IMAGE_TAG=$3

FMT="\033[38;5;106m%s\033[39m\n"
ERR="\033[38;5;208m%s\033[39m\n"

if [[ -v TRAVIS ]]; then
    (set -x; docker build --cache-from composer:latest --tag "$DOCKER_ORGANIZATION/$DOCKER_IMAGE:$DOCKER_IMAGE_TAG" --cache-from "$DOCKER_ORGANIZATION/$DOCKER_IMAGE:$DOCKER_IMAGE_TAG" $DOCKER_IMAGE/$DOCKER_IMAGE_TAG)
else
    (set -x; docker build --cache-from composer:latest --tag "$DOCKER_ORGANIZATION/$DOCKER_IMAGE:$DOCKER_IMAGE_TAG" $DOCKER_IMAGE/$DOCKER_IMAGE_TAG)
fi

printf ${FMT} "docker images"
docker images

if [[ $(docker images -q "$DOCKER_ORGANIZATION/$DOCKER_IMAGE" | wc -l) -eq 0 ]]; then
    >&2 printf ${ERR} "Unable to find image"
    exit 1
fi

printf ${FMT} "$DOCKER_IMAGE version"
docker run --rm --volume $PWD:/app --user=$(id -u):$(id -g) $DOCKER_ORGANIZATION/$DOCKER_IMAGE:$DOCKER_IMAGE_TAG --version

if [[ "$DOCKER_IMAGE" == "php" ]]; then

    printf ${FMT} "Write file as current user"
    docker run --rm --volume $PWD:/app --user=$(id -u):$(id -g) $DOCKER_ORGANIZATION/$DOCKER_IMAGE:$DOCKER_IMAGE_TAG php -r 'shell_exec("echo a > test-as-user");'
    if [[ $(stat -c '%u' test-as-user) != "$(id -u)" ]]; then
        [[ -v TRAVIS ]] || rm test-as-user
        >&2 printf ${ERR} "File test-as-user does not belong to current user"
        >&2 printf ${ERR} "Current user: $(id -u)"
        >&2 printf ${ERR} "File owner: $(stat -c '%u' test-as-user)"

        exit 1
    fi
    [[ -v TRAVIS ]] || rm test-as-user

    printf ${FMT} "Write file as root user"
    docker run --rm --volume $PWD:/app $DOCKER_ORGANIZATION/$DOCKER_IMAGE:$DOCKER_IMAGE_TAG php -r 'shell_exec("echo a > test-as-root");'
    if [[ $(stat -c '%u' test-as-root) != "0" ]]; then
        [[ -v TRAVIS ]] || sudo rm test-as-root
        >&2 printf ${ERR} "File test-as-root does not belong to root user"
        >&2 printf ${ERR} "Root user id: 0"
        >&2 printf ${ERR} "File owner id: $(stat -c '%u' test-as-root)"

        exit 1
    fi
    [[ -v TRAVIS ]] || sudo rm test-as-root

    printf ${FMT} "test disabling XDEBUG"

    if docker run --rm -e XDEBUG_ENABLED=0 --volume $PWD:/app $DOCKER_ORGANIZATION/$DOCKER_IMAGE:$DOCKER_IMAGE_TAG php -m | grep -q "xdebug"
    then
        >&2 printf ${ERR} "Unable to deactivate XDEBUG"
        exit 1
    fi
fi

exit 0
