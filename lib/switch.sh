#!/bin/bash

set -euo pipefail

source "${BASH_SOURCE%/*}/shared/utils.sh"

display_help() {
    echo "Usage: $0 <profile_name> [--global | --local]"
    echo
    echo "Switches the SSH and Git configurations to the specified profile."
    echo "By default, changes are applied to the current repository only."
    echo "Use '--global' to apply changes globally."
    echo
    echo "Example:"
    echo "  $0 myprofile         # Local switch"
    echo "  $0 myprofile --global # Global switch"
}

switch_profile() {
    local profile_name=$1
    local scope=${2:-local}
    local profile_dir="$(get_profile_dir "$profile_name")"

    if [ ! -d "$profile_dir" ]; then
        echo "Error: Profile '$profile_name' does not exist." >&2
        return 1
    fi

    local ssh_key=$(cat "$profile_dir/ssh_key")
    local email=$(cat "$profile_dir/email")
    local username=$(cat "$profile_dir/username")

    if [ "$scope" == "local" ]; then
        if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
            git config --local user.email "$email"
            git config --local user.name "$username"
            git config --local core.sshCommand "ssh -i $ssh_key"
        else
            echo "No Git repository found. Apply changes globally? [y/N]: "
            read -r confirmation
            if [[ $confirmation =~ ^[Yy]$ ]]; then
                scope="global"
            else
                echo "Local switch aborted."
                return 1
            fi
        fi
    fi

    if [ "$scope" == "global" ]; then
        git config --global user.email "$email"
        git config --global user.name "$username"
        git config --global core.sshCommand "ssh -i $ssh_key"
    fi

    echo "Switched to profile '$profile_name' ($scope)."
}

main() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help
        exit 0
    fi

    if [ "$#" -lt 1 ]; then
        echo "Error: Invalid number of arguments."
        display_help
        exit 1
    fi

    switch_profile "$1" "${2:-local}"
}

main "$@"
