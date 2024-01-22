#!/bin/bash

source "${BASH_SOURCE%/*}/shared/utils.sh"

list_profiles() {
    local profile_dir="$HOME/.mgc/profiles"

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
    list_profiles
}

main "$@"
