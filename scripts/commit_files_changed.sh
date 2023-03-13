#!/bin/bash
set -e

commit_updated_files=$(git diff-tree --no-commit-id --name-only "$GITHUB_SHA" -r)

echo "$commit_updated_files"

if [[ -n "$commit_updated_files" ]]
then
  echo "changed_files=$commit_updated_files" >> "$GITHUB_OUTPUT"
else
  echo "changed_files='none'" >> "$GITHUB_OUTPUT"
fi
