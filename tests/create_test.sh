#!/usr/bin/env bats

LIB_DIR="./lib"
TEST_MGC_BASE_DIR="./tmp-test-create"
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



@test "Create profile with short arguments" {
    bash $LIB_DIR/create.sh -n testProfile -k $SSH_KEY_PATH -e test@example.com -u testuser
    [ -d "$TEST_MGC_BASE_DIR/profiles/testProfile" ]
    [ "$(cat "$TEST_MGC_BASE_DIR/profiles/testProfile/ssh_key")" = "$SSH_KEY_PATH" ]
    [ "$(cat "$TEST_MGC_BASE_DIR/profiles/testProfile/email")" = "test@example.com" ]
    [ "$(cat "$TEST_MGC_BASE_DIR/profiles/testProfile/username")" = "testuser" ]
}

@test "Create profile with long arguments" {
    bash $LIB_DIR/create.sh --name testProfileLong --key $SSH_KEY_PATH --email test_long@example.com --username testuser_long
    [ -d "$TEST_MGC_BASE_DIR/profiles/testProfileLong" ]
    [ "$(cat "$TEST_MGC_BASE_DIR/profiles/testProfileLong/ssh_key")" = "$SSH_KEY_PATH" ]
    [ "$(cat "$TEST_MGC_BASE_DIR/profiles/testProfileLong/email")" = "test_long@example.com" ]
    [ "$(cat "$TEST_MGC_BASE_DIR/profiles/testProfileLong/username")" = "testuser_long" ]
}

@test "Fail to create profile without required arguments" {
    run bash $LIB_DIR/create.sh -n testProfileFail
    [ "$status" -ne 0 ]
}

@test "Display help with -h argument" {
    run bash $LIB_DIR/create.sh -h
    [ "$status" -eq 0 ]
    # check if lines start with "Usage"
    [[ "${lines[0]}" =~ ^Usage ]]
}
