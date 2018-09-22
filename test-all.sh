#!/usr/bin/env bash

# -e: exit as soon as a command exit with a non-zero status code
# -u: prevent from any undefined variable
# -o pipefail: force pipelines to fail on the first non-zero status code
set -euo pipefail
# Avoid using space as a separator (default IFS=$' \t\n')
IFS=$'\n\t'

declare docker_organizations=juliendufresne
declare software_name=
declare software_version=
declare php_version_file=

for dockerfile in $(find * -mindepth 2 -maxdepth 2 -name "Dockerfile"); do
    IFS="/" read -ra DOCKER_PARAMS <<< "$dockerfile"

    software_name="${DOCKER_PARAMS[0]}"
    software_version="${DOCKER_PARAMS[1]}"
    php_version_file=

    if [[ -f "${software_name}"/"${software_version}"/php.version ]]; then
        php_version_file="${software_name}"/"${software_version}"/php.version
    elif [[ -f "${software_name}"/php.version ]]; then
        php_version_file="${software_name}"/php.version
    fi

    if [[ -n "$php_version_file" ]]; then
        while IFS='' read -r line || [[ -n "$line" ]]; do
            (set -x; ./build.sh --php-version="$line" "${docker_organizations}" "${software_name}" "${software_version}")
            declare tag_name="$(./build.sh --show-tag --php-version="$line" "${docker_organizations}" "${software_name}" "${software_version}")"
            (set -x; ./test.sh "$docker_organizations/${software_name}:${tag_name}")
        done < "$php_version_file"
    else
        (set -x; ./build.sh  "${docker_organizations}" "${software_name}" "${software_version}")
        declare tag_name="$(./build.sh --show-tag "${docker_organizations}" "${software_name}" "${software_version}")"
        (set -x; ./test.sh "$docker_organizations/${software_name}:${tag_name}")
    fi
done
