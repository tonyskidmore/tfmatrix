#!/bin/bash

GITHUB_WORKSPACE=${GITHUB_WORKSPACE:-.}

config_compact_json=$(yq 'del(."changed_only")' -oj "$GITHUB_WORKSPACE/config.yml" | jq -c)

changed_only=$(yq '.changed_only' config.yml)

printf "compact json: %s\n" "$config_compact_json"
printf "changed_only: %s\n" "${changed_only,,}"
printf "CHANGED_FILES: \n%s\n" "$CHANGED_FILES"

echo "config=$config_compact_json" >> "$GITHUB_OUTPUT"

