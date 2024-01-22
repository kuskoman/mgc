#!/bin/bash

command_exists() {
    type "$1" &> /dev/null
}

load_profile_config() {
    local profile_name=$1
    local profile_dir="$HOME/.mgc/profiles/$profile_name"

    if [ ! -d "$profile_dir" ]; then
        echo "Error: Profile '$profile_name' does not exist." >&2
        return 1
    fi

    if [ -f "$profile_dir/config.sh" ]; then
        source "$profile_dir/config.sh"
    else
        echo "Error: Configuration file for profile '$profile_name' is missing." >&2
        return 1
    fi
}
