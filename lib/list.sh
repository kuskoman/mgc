#!/bin/bash

set -eo pipefail

source "${BASH_SOURCE%/*}/shared/utils.sh"

display_help() {
    echo "Usage: $0"
    echo
    echo "Lists all available profiles."
    echo
    echo "Example:"
    echo "  $0"
}

list_profiles() {
    local profile_dir
    profile_dir="$(get_mgc_base_dir)/profiles"

    if [ ! -d "$profile_dir" ] || [ -z "$(ls -A "$profile_dir")" ]; then
        echo "No profiles found."
        return 1
    fi

    echo "Available profiles:"
    for dir in "$profile_dir"/*; do
        if [ -d "$dir" ]; then
            echo " - $(basename "$dir")"
        fi
    done
}

main() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help
        exit 0
    fi

    list_profiles
}

main "$@"
