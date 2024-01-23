#!/usr/bin/env bats

LIB_DIR="./lib"
TEST_MGC_BASE_DIR="./tmp-test-remove"
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

simulate_remove_profile() {
    local profile_name=$1
    local confirmation=$2
    echo "$confirmation" | bash "$LIB_DIR/remove.sh" "$profile_name"
}

@test "Remove existing profile" {
    create_test_profile "testProfile"
    simulate_remove_profile "testProfile" "y"
    [ ! -d "$PROFILE_DIR/testProfile" ]
}

@test "Fail to remove non-existent profile" {
    run simulate_remove_profile "nonExistentProfile" "y"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error: Profile 'nonExistentProfile' does not exist."* ]]
}

@test "Cancel profile removal" {
    create_test_profile "testProfile"
    simulate_remove_profile "testProfile" "n"
    [ -d "$PROFILE_DIR/testProfile" ]
}
