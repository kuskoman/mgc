#!/usr/bin/env bats

LIB_DIR="./lib"
TEST_MGC_BASE_DIR="./tmp-test-show"
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

@test "Show profile when it exists" {
    create_test_profile "testProfile"
    run bash "$LIB_DIR/show.sh" "testProfile"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Profile: testProfile"* ]]
    [[ "$output" == *"SSH Key: /path/to/test/id_rsa"* ]]
    [[ "$output" == *"Email: test@example.com"* ]]
    [[ "$output" == *"Username: testuser"* ]]
}

@test "Fail to show a non-existent profile" {
    run bash "$LIB_DIR/show.sh" "nonExistentProfile"
    [ "$status" -ne 0 ]
    [[ "$output" == *"Error: Profile 'nonExistentProfile' not found."* ]]
}

@test "Display help with -h argument" {
    run bash "$LIB_DIR/show.sh" -h
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" =~ ^Usage ]]
}
