#!/bin/bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tests_dir="$script_dir/../tests"

for test in "$tests_dir"/*_test.sh; do
    echo "Running test: $test"
    bats "$test"
done
