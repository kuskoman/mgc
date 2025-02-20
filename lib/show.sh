#!/bin/bash

set -eo pipefail

source "${BASH_SOURCE%/*}/shared/utils.sh"

display_help() {
    echo "Usage: $0 <profile_name>"
    echo
    echo "Displays the details of a specific Git profile."
    echo
    echo "Example:"
    echo "  $0 testProfile"
}

show_profile() {
    local profile_name=$1
    local profile_dir
    profile_dir="$(get_profile_dir "$profile_name")"

    if [ ! -d "$profile_dir" ]; then
        echo "Error: Profile '$profile_name' not found." >&2
        exit 1
    fi

    echo "Profile: $profile_name"
    echo "SSH Key: $(cat "$profile_dir/ssh_key")"
    echo "Email: $(cat "$profile_dir/email")"
    echo "Username: $(cat "$profile_dir/username")"
}

main() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help
        exit 0
    fi

    if [ -z "$1" ]; then
        echo "Error: Missing profile name." >&2
        display_help >&2
        exit 1
    fi

    show_profile "$1"
}

main "$@"
