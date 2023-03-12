#!/bin/bash

GITHUB_WORKSPACE=${GITHUB_WORKSPACE:-.}

config_compact_json=$(yq -oj < "$GITHUB_WORKSPACE/config.yml" | jq -c)

printf "compact json: %s\n" "$config_compact_json"

echo "config=$config_compact_json" >> "$GITHUB_OUTPUT"
