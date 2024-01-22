#!/bin/bash

source "${BASH_SOURCE%/*}/shared/utils.sh"

__create_usage() {
    echo "Usage: $0 <profile_name> <ssh_key_path> <email> <username>"
}

verify_ssh_key() {
    local ssh_key=$1

    if [ ! -f "$ssh_key" ]; then
        echo "Error: SSH key '$ssh_key' does not exist." >&2
        return 1
    fi

    if ! command_exists ssh-keygen; then
        echo "Error: ssh-keygen is not installed." >&2
        return 1
    fi

    if ! ssh-keygen -l -f "$ssh_key" &> /dev/null; then
        echo "Error: '$ssh_key' is not a valid SSH key." >&2
        return 1
    fi
}

create_profile() {
    local profile_name=$1
    local ssh_key=$2
    local email=$3
    local username=$4
    local profile_dir="$HOME/.mgc/profiles/$profile_name"

    if [ -d "$profile_dir" ]; then
        echo "Error: Profile '$profile_name' already exists." >&2
        return 1
    fi

    verify_ssh_key "$ssh_key" || return 1

    mkdir -p "$profile_dir"
    echo "$ssh_key" > "$profile_dir/ssh_key"
    echo "$email" > "$profile_dir/email"
    echo "$username" > "$profile_dir/username"

    echo "Profile '$profile_name' created successfully."
}



main() {
    if [ "$1" = "--help" ]; then
        __create_usage
        exit 0
    fi

    if [ "$#" -ne 4 ]; then
        echo "Error: Invalid number of arguments. Expected 4, got $#" >&2
        __create_usage >&2
        exit 1
    fi

    create_profile "$1" "$2" "$3" "$4"
}

main "$@"
