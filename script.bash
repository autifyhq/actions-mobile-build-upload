#!/usr/bin/env bash

ARGS=()

function add_args() {
  ARGS+=("$1")
}

function exit_script() {
  local code=$1
  echo ::set-output name=exit-code::"$code"
  exit "$code"
}

AUTIFY=${INPUT_AUTIFY_PATH}

if [ -z "${INPUT_ACCESS_TOKEN}" ]; then
  echo "Missing access-token."
  exit_script 1
fi

if [ -n "${INPUT_BUILD_PATH}" ]; then
  add_args "${INPUT_BUILD_PATH}"
else
  echo "Missing build-path."
  exit_script 1
fi

if [ -n "${INPUT_WORKSPACE_ID}" ]; then
  add_args "--workspace-id=${INPUT_WORKSPACE_ID}"
else
  echo "Missing workspace-id."
  exit_script 1
fi

OUTPUT=$(mktemp)
AUTIFY_MOBILE_ACCESS_TOKEN=${INPUT_ACCESS_TOKEN} ${AUTIFY} mobile build upload "${ARGS[@]}" 2>&1 | tee "$OUTPUT"
exit_code=${PIPESTATUS[0]}

# Workaround to return multiline string as outputs
# https://trstringer.com/github-actions-multiline-strings/
output=$(cat "$OUTPUT")
output="${output//'%'/%25}"
output="${output//$'\n'/%0A}"
output="${output//$'\r'/%0D}"
echo ::set-output name=log::"$output"

build_id=$(grep "Successfully uploaded" "$OUTPUT" | grep -Eo 'ID: [^\)]+' | cut -f2 -d' ' | head -1)
echo ::set-output name=build-id::"$build_id"

exit_script "$exit_code"
