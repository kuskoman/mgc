#!/bin/bash

source "${BASH_SOURCE%/*}/shared/utils.sh"

display_help() {
    echo "Usage: $0 [--name <profile_name> | -n <profile_name>]"
    echo "          [--key <ssh_key_path> | -k <ssh_key_path>]"
    echo "          [--email <email> | -e <email>]"
    echo "          [--username <username> | -u <username>]"
    echo
    echo "Creates a new profile with the specified SSH key, email, and username."
    echo
    echo "Example:"
    echo "  $0 --name myprofile --key /path/to/ssh_key --email myemail@example.com --username myusername"
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
    local profile_dir=$(get_profile_dir "$profile_name")

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
    local profile_name=""
    local ssh_key=""
    local email=""
    local username=""

    while [[ "$#" -gt 0 ]]; do
        key="$1"
        case $key in
            -n|--name)
                profile_name="$2"
                shift 2
                ;;
            -k|--key)
                ssh_key="$2"
                shift 2
                ;;
            -e|--email)
                email="$2"
                shift 2
                ;;
            -u|--username)
                username="$2"
                shift 2
                ;;
            -h|--help)
                display_help
                exit 0
                ;;
            *)
                echo "Unknown option: $1" >&2
                display_help >&2
                exit 1
                ;;
        esac
    done

    if [ -z "$profile_name" ] || [ -z "$ssh_key" ] || [ -z "$email" ] || [ -z "$username" ]; then
        echo "Error: Missing arguments." >&2
        display_help >&2
        exit 1
    fi

    create_profile "$profile_name" "$ssh_key" "$email" "$username"
}

main "$@"
