#!/bin/bash

GITHUB_WORKSPACE=${GITHUB_WORKSPACE:-.}

config=$(< "$GITHUB_WORKSPACE/config.yml")

changed_only=$(yq '.changed_only' <<< "$config")
targets=($(yq -r '.target[]' <<< "$config"))
environments=($(yq -r '.environment[]' <<< "$config"))
matrix_config=$(yq 'del(."changed_only")' -oj <<< "$config")

declare -p targets
declare -p environments
declare -p CHANGED_FILES

printf "matrix config: %s\n" "$matrix_config"
printf "changed_only: %s\n" "${changed_only,,}"
printf "CHANGED_FILES: \n%s\n" "$CHANGED_FILES"


if [[ "${changed_only,,}" == "true" ]]
then
  for target in "${targets[@]}"
  do
    printf "target: %s\n" "$target"
    if grep -q "terraform/$target" <<< "$CHANGED_FILES"
    then
      # if base terraform has been updated for any target (e.g. local, azure or aws)
      # then all environments are in scope (e.g. dev, tst, prd)
      echo "Adding all enabled environments from matrix"
      matrix_config=$(jq -r '.environment = $ARGS.positional' --args "${environments[@]}" <<< "$matrix_config")
      all_envs=1
      break
    fi
  done
  # if all environments have not already been declared as required then remove them selectively
  if [[ -z "$all_envs" ]]
  then
    for environment in "${environments[@]}"
    do
        printf "environment: %s\n" "$environment"

        if ! grep -q "environments/$environment" <<< "$CHANGED_FILES"
        then
          echo "Removing $environment from matrix"
          matrix_config=$(jq -r --arg ENVIRON "$environment" 'del(.environment[] | select(.==$ENVIRON ))' <<< "$matrix_config")
        fi
    done
  fi
fi

# there must be at least one target and one environment
# if not set the output as '{}', whihc will cause the terraform job to be skipped
env_count=$(jq -r '.environment | length' <<< "$matrix_config")
[[ "$env_count" == "0" ]] && matrix_config='{}'
tgt_count=$(jq -r '.target | length' <<< "$matrix_config")
[[ "$tgt_count" == "0" ]] && matrix_config='{}'

jq <<< "$matrix_config"

config_compact_json=$(jq -c <<< "$matrix_config")
printf "compact json: %s\n" "$config_compact_json"
echo "config=$config_compact_json" >> "$GITHUB_OUTPUT"
