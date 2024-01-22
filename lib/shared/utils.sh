#!/bin/bash

command_exists() {
    type "$1" &> /dev/null
}

get_mgc_base_dir() {
    if [ -n "${MGC_DIR:-}" ]; then
        echo "$MGC_DIR"
    else
        echo "$HOME/.mgc"
    fi
}

get_profile_dir() {
    local profile_name=$1
    echo "$(get_mgc_base_dir)/profiles/$profile_name"
}
