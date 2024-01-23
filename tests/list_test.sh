#!/usr/bin/env bats

LIB_DIR="./lib"
TEST_MGC_BASE_DIR="./tmp-test-list"
PROFILE_DIR="$TEST_MGC_BASE_DIR/.mgc/profiles"

setup() {
    MGC_DIR="$TEST_MGC_BASE_DIR/.mgc"
    export MGC_DIR

    mkdir -p "$PROFILE_DIR"
}

teardown() {
    rm -rf "$TEST_MGC_BASE_DIR"
}

create_test_profile() {
    local profile_name=$1
    mkdir -p "$PROFILE_DIR/$profile_name"
    echo "/path/to/test/id_rsa" > "$PROFILE_DIR/$profile_name/ssh_key"
    echo "test@example.com" > "$PROFILE_DIR/$profile_name/email"
    echo "testuser" > "$PROFILE_DIR/$profile_name/username"
}

@test "List profiles when none exist" {
    run bash "$LIB_DIR/list.sh"
    [ "$status" -eq 1 ]
    [[ "$output" == "No profiles found." ]]
}

@test "List single profile" {
    create_test_profile "testProfile"
    run bash "$LIB_DIR/list.sh"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Available profiles:"* ]]
    [[ "$output" == *" - testProfile"* ]]
}

@test "List multiple profiles" {
    create_test_profile "profileOne"
    create_test_profile "profileTwo"
    run bash "$LIB_DIR/list.sh"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Available profiles:"* ]]
    [[ "$output" == *" - profileOne"* ]]
    [[ "$output" == *" - profileTwo"* ]]
}
