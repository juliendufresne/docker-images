#!/usr/bin/env bash

# -e: exit as soon as a command exit with a non-zero status code
# -u: prevent from any undefined variable
# -o pipefail: force pipelines to fail on the first non-zero status code
set -euo pipefail
# Avoid using space as a separator (default IFS=$' \t\n')
IFS=$'\n\t'

declare -g DOCKER_TAG
declare -g current_script_dir
current_script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly current_script_dir

function error
{
    >&2 printf '\033[38;5;208m%s\033[39m\n' "$1"
}

function main
{
    declare docker_organization=
    declare software_name=
    declare software_version=

    declare show_tag=false
    declare php_version=
    declare travis=false

    while [[ "$#" -gt 0 ]]; do
        declare key="$1"
        case "$key" in
            --php-version=*)
                php_version="${1#*=}"
                ;;
            --travis)
                travis=true
                ;;
            --show-tag)
                show_tag=true
                ;;
            -*)
                error "Unknown option $1"

                return 1
                ;;
            *)
                if [[ -z "$docker_organization" ]]; then
                    docker_organization="$1"
                elif [[ -z "$software_name" ]]; then
                    software_name="$1"
                elif [[ -z "$software_version" ]]; then
                    software_version="$1"
                else
                    error "Unknown argument $1"

                    return 1
                fi
                ;;
        esac
        shift
    done

    if [[ -z "$docker_organization" ]]; then
        error "Missing argument docker_organization"

        return 1
    fi

    if [[ -z "$software_name" ]]; then
        error "Missing argument software_name"

        return 1
    fi

    if ! [[ -d "$current_script_dir/$software_name/$software_version" ]]; then
        error "$software_name/$software_version: directory does not exist"

        return 1
    fi

    # produce DOCKER_TAG variable
    extract_docker_tag "$software_version" "$php_version"

    if $show_tag; then
        echo "$DOCKER_TAG"
        return 0
    fi

    cd "$current_script_dir/$software_name/$software_version"
    build_docker_image "$docker_organization/$software_name:$DOCKER_TAG" "$php_version" ${travis}

    return 0
}
readonly -f "main"

function build_docker_image
{
    declare -r image="$1"
    declare -r php_version="$2"
    declare -r travis=$3

    declare -a build_options=("--tag" "$image")

    if [[ -n "$php_version" ]]; then
        build_options+=("--build-arg" "PHP_VERSION=$php_version")
    fi

    if $travis; then
        build_options+=("--cache-from" "$image")
    fi

    (
        set -x;
        docker build "${build_options[@]}" .
    )
}
readonly -f "build_docker_image"

function extract_docker_tag
{
    declare -r software_version="$1"
    declare -r php_version="$2"

    DOCKER_TAG="$software_version"
    if [[ -n "$php_version" ]]; then
        DOCKER_TAG="$DOCKER_TAG-php$php_version"
    fi
}
readonly -f "extract_docker_tag"

main "$@"
