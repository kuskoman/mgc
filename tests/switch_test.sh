#!/usr/bin/env bats

LIB_DIR="$(pwd)/lib"
TEST_MGC_BASE_DIR="$(mktemp -d)/tmp-test-switch"
PROFILE_DIR="$TEST_MGC_BASE_DIR/.mgc/profiles"
FAKE_REPO_DIR="$TEST_MGC_BASE_DIR/fake-repo"

setup() {
    backup_git_config

    MGC_DIR="$TEST_MGC_BASE_DIR/.mgc"
    export MGC_DIR

    mkdir -p "$PROFILE_DIR"
    mkdir -p "$FAKE_REPO_DIR"
    git init "$FAKE_REPO_DIR"

    create_test_profile "testProfile" "/path/to/test/id_rsa" "test@example.com" "testuser"
}

teardown() {
    rm -rf "$TEST_MGC_BASE_DIR"
    restore_git_config
}

backup_git_config() {
    if [ ! -f "$HOME/.gitconfig" ]; then
        return
    fi
    cp "$HOME/.gitconfig" "$HOME/.gitconfig.bak"
}

restore_git_config() {
    if [ ! -f "$HOME/.gitconfig.bak" ]; then
        return
    fi
    cp "$HOME/.gitconfig.bak" "$HOME/.gitconfig"
    rm "$HOME/.gitconfig.bak"
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
    cd "$TEST_MGC_BASE_DIR" || return 1

    local initial_email
    initial_email=$(git config user.email)
    local initial_name
    initial_name=$(git config user.name)
    local initial_ssh_command
    initial_ssh_command=$(git config core.sshCommand)

    run bash -c "echo 'n' | $LIB_DIR/switch.sh testProfile"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Local switch aborted."* ]]
    [ "$(git config user.email)" = "$initial_email" ]
    [ "$(git config user.name)" = "$initial_name" ]
    [ "$(git config core.sshCommand)" = "$initial_ssh_command" ]
}

@test "Confirm global switch in non-git directory" {
    cd "$(mktemp -d)" || return 1
    echo "y" | bash "$LIB_DIR/switch.sh" testProfile
    [ "$(git config --global user.email)" = "test@example.com" ]
    [ "$(git config --global user.name)" = "testuser" ]
    [ "$(git config --global core.sshCommand)" = "ssh -i /path/to/test/id_rsa" ]
}
