#!/bin/bash

set -euo pipefail

source "${BASH_SOURCE%/*}/shared/utils.sh"

display_help() {
    echo "Usage: $0 <repository_url> <profile_name>"
    echo
    echo "Clones a repository using the specified profile's SSH key."
    echo "Sets local Git configurations based on the profile."
    echo
    echo "Example:"
    echo "  $0 git@github.com:user/repo.git myprofile"
}

clone_repo() {
    local repo_url=$1
    local profile_name=$2
    local profile_dir="$(get_profile_dir "$profile_name")"

    if [ ! -d "$profile_dir" ]; then
        echo "Error: Profile '$profile_name' does not exist." >&2
        return 1
    fi

    local ssh_key=$(cat "$profile_dir/ssh_key")
    local email=$(cat "$profile_dir/email")
    local username=$(cat "$profile_dir/username")

    GIT_SSH_COMMAND="ssh -i $ssh_key" git clone "$repo_url"
    local repo_name=$(basename "$repo_url" .git)

    cd "$repo_name" || return

    git config --local user.email "$email"
    git config --local user.name "$username"
}

main() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help
        exit 0
    fi

    if [ "$#" -ne 2 ]; then
        echo "Error: Invalid number of arguments."
        display_help
        exit 1
    fi

    clone_repo "$1" "$2"
}

main "$@"
