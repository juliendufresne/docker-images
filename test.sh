#!/usr/bin/env bash

# -e: exit as soon as a command exit with a non-zero status code
# -u: prevent from any undefined variable
# -o pipefail: force pipelines to fail on the first non-zero status code
set -euo pipefail
# Avoid using space as a separator (default IFS=$' \t\n')
IFS=$'\n\t'


function error
{
    >&2 printf '\033[38;5;208m%s\033[39m\n' "$1"
}

function output
{
    printf '\033[38;5;106m%s\033[39m\n' "$1"
}

function main
{
    declare current_script_dir
    current_script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    readonly current_script_dir

    declare docker_image=

    while [[ "$#" -gt 0 ]]; do
        declare key="$1"
        case "$key" in
            -*)
                error "Unknown option $1"

                return 1
                ;;
            *)
                if [[ -z "$docker_image" ]]; then
                    docker_image="$1"
                else
                    error "Unknown argument $1"

                    return 1
                fi
                ;;
        esac
        shift
    done

    list_docker_images
    check_image_exist "$docker_image"
    check_software_version "$docker_image"

    if [[ "$docker_image" == *php* ]]; then
        check_file_permission "$docker_image" "user" "$(id -u)"
        check_file_permission "$docker_image" "root" "0"
        check_activate_xdebug "$docker_image" "$(id -u)"
        check_activate_xdebug "$docker_image" "0"
    fi

    return 0
}
readonly -f "main"

function list_docker_images
{
    output "List known docker images"
    docker images
}
readonly -f "list_docker_images"

function check_activate_xdebug
{
    declare -r docker_image="$1"
    declare -r user_id="$2"

    declare -a options=("--rm" "--volume" "$PWD:/app")

    if [[ "$user_id" -ne 0 ]]; then
        options+=("--user" "$user_id")
    fi

    output "Check activate xdebug"

    if ! (set -x; docker run "${options[@]}" -e XDEBUG_ENABLED=1 "$docker_image" php -m) | grep -q xdebug; then
        error "unable to activate xdebug"
        return 1
    fi

    output "OK"

    return 0
}
readonly -f "check_activate_xdebug"

function check_file_permission
{
    declare -r docker_image="$1"
    declare -r user_name="$2"
    declare -r user_id="$3"

    declare filename="test-as-$user_name"
    declare -a options=("--rm" "--volume" "$PWD:/app")

    if [[ "$user_id" -ne 0 ]]; then
        options+=("--user" "$user_id")
    fi

    output "Check file permission with user $user_name"

    (set -x; docker run "${options[@]}" "$docker_image" touch "$filename")

    declare file_owner
    file_owner="$(stat -c '%u' "$filename")"
    readonly file_owner

    rm --interactive=never "$filename"

    if [[ "$file_owner" != "$user_id" ]]; then
        error "File $filename does not belong to current user"
        error "Expected user id: $user_id"
        error "File owner: $(stat -c '%u' "$filename")"

        return 1
    fi

    return 0
}
readonly -f "check_file_permission"

function check_image_exist
{
    declare -r docker_image="$1"

    output "Check image exist"
    if [[ $(docker images -q "$docker_image" | wc -l) -eq 0 ]]; then
        error "Image $docker_image does not exists"
    else
        output "OK"
    fi
}
readonly -f "check_image_exist"

function check_software_version
{
    declare -r docker_image="$1"
    output "Check software version"
    (set -x; docker run --rm --volume "$PWD":/app "$docker_image" --version)
}
readonly -f "check_software_version"

main "$@"
