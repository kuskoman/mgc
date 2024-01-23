#!/usr/bin/env bats

LIB_DIR="$(pwd)/../lib"
TEST_MGC_BASE_DIR="$(pwd)/tmp-test-switch"
PROFILE_DIR="$TEST_MGC_BASE_DIR/.mgc/profiles"
FAKE_REPO_DIR="$TEST_MGC_BASE_DIR/fake-repo"

setup() {
    MGC_DIR="$TEST_MGC_BASE_DIR/.mgc"
    export MGC_DIR

    mkdir -p "$PROFILE_DIR"
    mkdir -p "$FAKE_REPO_DIR"
    git init "$FAKE_REPO_DIR"

    create_test_profile "testProfile" "/path/to/test/id_rsa" "test@example.com" "testuser"
}

teardown() {
    rm -rf "$TEST_MGC_BASE_DIR"
}

create_test_profile() {
    local profile_name=$1
    local ssh_key=$2
    local email=$3
    local username=$4

    mkdir -p "$PROFILE_DIR/$profile_name"
    echo "$ssh_key" > "$PROFILE_DIR/$profile_name/ssh_key"
    echo "$email" > "$PROFILE_DIR/$profile_name/email"
    echo "$username" > "$PROFILE_DIR/$profile_name/username"
}

@test "Switch to existing profile locally" {
    cd "$FAKE_REPO_DIR" || return 1
    bash "$LIB_DIR/switch.sh" testProfile --local
    [ "$(git config user.email)" = "test@example.com" ]
    [ "$(git config user.name)" = "testuser" ]
    [ "$(git config core.sshCommand)" = "ssh -i /path/to/test/id_rsa" ]
}

@test "Switch to non-existent profile" {
    run bash "$LIB_DIR/switch.sh" nonExistentProfile --local
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error: Profile 'nonExistentProfile' does not exist."* ]]
}

@test "Switch to existing profile globally" {
    bash "$LIB_DIR/switch.sh" testProfile --global
    [ "$(git config --global user.email)" = "test@example.com" ]
    [ "$(git config --global user.name)" = "testuser" ]
    [ "$(git config --global core.sshCommand)" = "ssh -i /path/to/test/id_rsa" ]
}

@test "Abort local switch in non-git directory" {
    run bash "$LIB_DIR/switch.sh" testProfile --local
    [ "$status" -eq 1 ]
    [[ "$output" == *"Local switch aborted."* ]]
}

simulate_yes_confirmation() {
    echo "y" | bash "$LIB_DIR/switch.sh" testProfile
}

@test "Confirm global switch in non-git directory" {
    simulate_yes_confirmation
    [ "$(git config --global user.email)" = "test@example.com" ]
    [ "$(git config --global user.name)" = "testuser" ]
    [ "$(git config --global core.sshCommand)" = "ssh -i /path/to/test/id_rsa" ]
}
