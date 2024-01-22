#!/bin/bash

set -euo pipefail

source "${BASH_SOURCE%/*}/shared/utils.sh"

display_help() {
    echo "Usage: $0 <profile_name>"
    echo
    echo "Removes the specified profile."
    echo "This will delete the profile's directory and all its associated configurations."
    echo
    echo "Example:"
    echo "  $0 myprofile"
}

remove_profile() {
    local profile_name=$1
    local profile_dir="$HOME/.mgc/profiles/$profile_name"

    if [ ! -d "$profile_dir" ]; then
        echo "Error: Profile '$profile_name' does not exist." >&2
        return 1
    fi

    echo "The following profile directory will be removed: $profile_dir"
    echo "Contents:"
    ls -A "$profile_dir"

    echo -n "Are you sure you want to remove this profile? [y/N]: "
    read -r confirmation
    if [[ $confirmation =~ ^[Yy]$ ]]; then
        rm -rf "$profile_dir"
        echo "Profile '$profile_name' removed successfully."
    else
        echo "Profile removal cancelled."
    fi
}

main() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help
        exit 0
    fi

    if [ "$#" -ne 1 ]; then
        display_help >&2
        exit 1
    fi

    remove_profile "$1"
}

main "$@"
