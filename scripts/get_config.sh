#!/bin/bash

GITHUB_WORKSPACE=${GITHUB_WORKSPACE:-.}

config=$(< "$GITHUB_WORKSPACE/config.yml")

changed_only=$(yq '.changed_only' <<< "$config")
targets=($(yq -r '.target[]' <<< "$config"))
environments=($(yq -r '.environment[]' <<< "$config"))
matrix_config=$(yq 'del(."changed_only")' -oj <<< "$config")


# changed_only=$(yq '.changed_only' config.yml)

# matrix_config=$(yq 'del(."changed_only")' -oj "$GITHUB_WORKSPACE/config.yml")
# config_compact_json=$(jq -c <<< "$matrix_config")
# targets=$(yq -r '.targets[]' config.yml)

declare -p targets
declare -p environments
declare -p CHANGED_FILES

printf "matrix config: %s\n" "$matrix_config"
printf "compact json: %s\n" "$config_compact_json"
printf "changed_only: %s\n" "${changed_only,,}"
printf "CHANGED_FILES: \n%s\n" "$CHANGED_FILES"

#TODO: handle changed files processing
# if there were no updates in the names environment e.g.
# environments/dev
# environments/prd
# environments/tst
# or no updated in the nameds targets e.g
# terraform/aws
# terraform/azure
# terraform/local
# then remove from the matrix

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
    else
      # remove from matrix if target code has not been updated
      matrix_config=$(jq -r --arg TARGET "$target" 'del(.target[] | select(.==$TARGET))' <<< "$matrix_config")
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

env_count=$(jq -r '.environment | length' <<< "$matrix_config")
[[ "$env_count" == "0" ]] && matrix_config='{}'
tgt_count=$(jq -r '.target | length' <<< "$matrix_config")
[[ "$tgt_count" == "0" ]] && matrix_config='{}'
# [[ "$env_count" == "0" ]] && matrix_config=$(jq -r 'del(.environment)' <<< "$matrix_config")
# [[ "$tgt_count" == "0" ]] && matrix_config=$(jq -r 'del(.target)' <<< "$matrix_config")

jq <<< "$matrix_config"

config_compact_json=$(jq -c <<< "$matrix_config")
echo "config=$config_compact_json" >> "$GITHUB_OUTPUT"
