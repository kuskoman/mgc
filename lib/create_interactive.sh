#!/bin/bash

set -eo pipefail

source "${BASH_SOURCE%/*}/shared/utils.sh"

display_help() {
    echo "Usage: $0"
    echo
    echo "Interactively creates a new Git profile by prompting for details."
    echo
    echo "Example:"
    echo "  $0"
}

prompt_input() {
    local prompt_message="$1"
    local var_name="$2"

    while true; do
        read -rp "$prompt_message: " input
        if [ -n "$input" ]; then
            eval "$var_name=\"$input\""
            break
        else
            echo "Error: This field cannot be empty."
        fi
    done
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
    local profile_dir
    profile_dir=$(get_profile_dir "$profile_name")

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
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help
        exit 0
    fi

    echo "Creating a new Git profile interactively."

    prompt_input "Enter profile name" profile_name
    prompt_input "Enter SSH key path" ssh_key
    prompt_input "Enter email address" email
    prompt_input "Enter Git username" username

    create_profile "$profile_name" "$ssh_key" "$email" "$username"
}

main "$@"
