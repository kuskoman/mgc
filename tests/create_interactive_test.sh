#!/usr/bin/env bats

LIB_DIR="./lib"
TEST_MGC_BASE_DIR="./tmp-test-create-interactive"
SSH_KEY_PATH="$TEST_MGC_BASE_DIR/id_rsa"

setup() {
    MGC_DIR="$TEST_MGC_BASE_DIR"
    export MGC_DIR

    mkdir -p "$MGC_DIR/profiles"

    ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH" -q -N ""
}

teardown() {
    rm -rf "$TEST_MGC_BASE_DIR"
}

@test "Create profile interactively" {
    run bash -c "printf 'testProfile\n$SSH_KEY_PATH\ntest@example.com\ntestuser\n' | bash $LIB_DIR/create_interactive.sh"
    [ "$status" -eq 0 ]
    [ -d "$TEST_MGC_BASE_DIR/profiles/testProfile" ]
    [ "$(cat "$TEST_MGC_BASE_DIR/profiles/testProfile/ssh_key")" = "$SSH_KEY_PATH" ]
    [ "$(cat "$TEST_MGC_BASE_DIR/profiles/testProfile/email")" = "test@example.com" ]
    [ "$(cat "$TEST_MGC_BASE_DIR/profiles/testProfile/username")" = "testuser" ]
}

@test "Fail to create profile if SSH key is missing" {
    run bash -c "printf 'testProfile\n/nonexistent_key\ntest@example.com\ntestuser\n' | bash $LIB_DIR/create_interactive.sh"
    [ "$status" -ne 0 ]
    [[ "$output" == *"Error: SSH key '/nonexistent_key' does not exist."* ]]
}
