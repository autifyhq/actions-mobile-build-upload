#!/usr/bin/env bash

log_file=$(dirname "$0")/log
log_fail_file=$(dirname "$0")/log-fail

function before() {
  unset INPUT_AUTIFY_PATH
  unset INPUT_ACCESS_TOKEN
  unset INPUT_BUILD_PATH
  unset INPUT_WORKSPACE_ID
  echo "=== TEST ==="
}

function test_command() {
  local expected=$1
  local result
  result=$(./script.bash | head -1)

  if [ "$result" == "$expected" ]; then
    echo "Passed command: $expected"
  else
    echo "Failed command:"
    echo "  Expected: $expected"
    echo "  Result  : $result"
    exit 1
  fi
}

function test_code() {
  local expected=$1
  ./script.bash > /dev/null
  local result=$?

  if [ "$result" == "$expected" ]; then
    echo "Passed code: $expected"
  else
    echo "Failed code:"
    echo "  Expected: $expected"
    echo "  Result  : $result"
    exit 1
  fi
}

function test_log() {
  local file=$1
  local result
  result=$(mktemp)
  ./script.bash | tail -n+2 | grep -E -v ^::set-output > "$result"

  if (git diff --no-index --quiet -- "$file" "$result"); then
    echo "Passed log:"
  else
    echo "Failed log:"
    git --no-pager diff --no-index -- "$file" "$result"
    exit 1
  fi
}

function test_output() {
  local name=$1
  local expected
  expected=$(mktemp)
  echo -e "$2" > "$expected"
  local output
  output=$(./script.bash | grep -E ^::set-output | grep name="${name}":: | awk -F'::' '{print $3}')
  output="${output//'%25'/%}"
  output="${output//'%0A'/$'\n'}"
  output="${output//'%0D'/$'\r'}"
  local result
  result=$(mktemp)
  echo -e "$output" > "$result"

  if (git diff --no-index --quiet -- "$expected" "$result"); then
    echo "Passed output: $name"
  else
    echo "Failed output: $name"
    git --no-pager diff --no-index -- "$expected" "$result"
    exit 1
  fi
}

{
  before
  export INPUT_AUTIFY_PATH="./test/autify-mock"
  export INPUT_ACCESS_TOKEN=token
  export INPUT_BUILD_PATH=a
  export INPUT_WORKSPACE_ID=b
  test_command "autify mobile build upload a --workspace-id=b"
  test_code 0
  test_log "$log_file"
  test_output exit-code "0"
  test_output log "autify mobile build upload a --workspace-id=b\n$(cat "$log_file")"
  test_output build-id "BBB"
}

{
  before
  export INPUT_AUTIFY_PATH="./test/autify-mock-fail"
  export INPUT_ACCESS_TOKEN=token
  export INPUT_BUILD_PATH=a
  export INPUT_WORKSPACE_ID=b
  test_command "autify-fail mobile build upload a --workspace-id=b"
  test_code 1
  test_log "$log_fail_file"
  test_output exit-code "1"
  test_output log "autify-fail mobile build upload a --workspace-id=b\n$(cat "$log_fail_file")"
  test_output build-id ""
}
