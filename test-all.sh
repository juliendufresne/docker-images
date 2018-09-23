#!/usr/bin/env bash

# -e: exit as soon as a command exit with a non-zero status code
# -u: prevent from any undefined variable
# -o pipefail: force pipelines to fail on the first non-zero status code
set -euo pipefail
# Avoid using space as a separator (default IFS=$' \t\n')
IFS=$'\n\t'

declare docker_organizations
docker_organizations=juliendufresne
readonly docker_organizations

function main
{
    check_shell_files
    find . -mindepth 3 -maxdepth 3 -name "Dockerfile" -print0 |
        while IFS= read -r -d $'\0' dockerfile; do
            launch_for_dockerfile "$dockerfile"
        done
}
readonly -f "main"

function check_shell_files
{
    find . \( -name "*.sh" -o -name "Dockerfile" \) -print0 |
        while IFS= read -r -d $'\0' shellfile; do
            (set -x; shellcheck "$shellfile")
        done
}
readonly -f "check_shell_files"

function launch_for_dockerfile
{
    declare dockerfile
    declare software_name
    declare software_version
    declare php_version_file
    declare tag_name

    dockerfile="$1"
    readonly dockerfile
    declare -a docker_params
    IFS="/" read -ra docker_params <<< "$dockerfile"

    software_name="${docker_params[-3]}"
    software_version="${docker_params[-2]}"

    php_version_file=""
    if [[ -f "${software_name}"/"${software_version}"/php.version ]]; then
        php_version_file="${software_name}"/"${software_version}"/php.version
    elif [[ -f "${software_name}"/php.version ]]; then
        php_version_file="${software_name}"/php.version
    fi

    if [[ -n "$php_version_file" ]]; then
        while IFS='' read -r php_version || [[ -n "$php_version" ]]; do
            launch_single "$software_name" "$software_version" "$php_version"
        done < "$php_version_file"
    else
        launch_single "$software_name" "$software_version"
    fi
}
readonly -f "launch_for_dockerfile"

function launch_single
{
    declare software_name
    declare software_version
    declare php_version
    declare tag_name

    software_name="$1"
    software_version="$2"
    php_version="${3:-}"

    (set -x; ./build.sh --php-version="$php_version" "${docker_organizations}" "${software_name}" "${software_version}")
    tag_name="$(./build.sh --show-tag --php-version="$php_version" "${docker_organizations}" "${software_name}" "${software_version}")"
    (set -x; ./test.sh "$docker_organizations/${software_name}:${tag_name}")
}
readonly -f "launch_single"

main
