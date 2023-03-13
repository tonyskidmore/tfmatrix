#!/bin/bash

GITHUB_WORKSPACE=${GITHUB_WORKSPACE:-.}

config=$(< "$GITHUB_WORKSPACE/config.yml")

changed_only=$(yq '.changed_only' <<< "$config")
targets=($(yq -r '.target[]' <<< "$config"))
environments=($(yq -r '.environment[]' <<< "$config"))

matrix_config=$(yq 'del(."changed_only")' -oj <<< "$config")
config_compact_json=$(jq -c <<< "$matrix_config")

# changed_only=$(yq '.changed_only' config.yml)

# matrix_config=$(yq 'del(."changed_only")' -oj "$GITHUB_WORKSPACE/config.yml")
# config_compact_json=$(jq -c <<< "$matrix_config")
# targets=$(yq -r '.targets[]' config.yml)

declare -p targets
declare -p environments

printf "matrix config: %s\n" "$matrix_config"
printf "compact json: %s\n" "$config_compact_json"
printf "changed_only: %s\n" "${changed_only,,}"
printf "CHANGED_FILES: \n%s\n" "$CHANGED_FILES"

#TODO: handle changed files processing

echo "config=$config_compact_json" >> "$GITHUB_OUTPUT"
