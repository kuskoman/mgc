#!/usr/bin/env bats

LIB_DIR="./lib"
TEST_MGC_BASE_DIR="./tmp-test-clone"
SSH_KEY_PATH="$TEST_MGC_BASE_DIR/id_rsa"
FAKE_REMOTE_REPO="$TEST_MGC_BASE_DIR/fake-remote-repo.git"
FAKE_LOCAL_REPO="$TEST_MGC_BASE_DIR/fake-local-repo"

setup() {
    setup_directories_and_profile
    initialize_fake_remote_repo
}

teardown() {
    rm -rf "$TEST_MGC_BASE_DIR"
}

setup_directories_and_profile() {
    MGC_DIR="$TEST_MGC_BASE_DIR/.mgc"
    export MGC_DIR

    TEST_PROFILE_DIR="$MGC_DIR/profiles/testProfile"
    mkdir -p "$TEST_PROFILE_DIR"

    if [ ! -f "$SSH_KEY_PATH" ]; then
        ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH" -q -N ""
    fi

    echo "$SSH_KEY_PATH" > "$TEST_PROFILE_DIR/ssh_key"
    echo "test@example.com" > "$TEST_PROFILE_DIR/email"
    echo "testuser" > "$TEST_PROFILE_DIR/username"
}

initialize_fake_remote_repo() {
    mkdir -p "$FAKE_REMOTE_REPO"
    git init --bare "$FAKE_REMOTE_REPO"
}

@test "Clone repository and set local config" {
    bash "$LIB_DIR/clone.sh" "$FAKE_REMOTE_REPO" testProfile "$FAKE_LOCAL_REPO"

    pushd "$FAKE_LOCAL_REPO" || return 1
    [ -d ".git" ]
    [ "$(git config user.email)" = "test@example.com" ]
    [ "$(git config user.name)" = "testuser" ]
    popd
}

@test "Fail to clone with non-existent profile" {
    run bash "$LIB_DIR/clone.sh" "$FAKE_REMOTE_REPO" nonExistentProfile "$FAKE_LOCAL_REPO"
    [ "$status" -ne 0 ]
}
