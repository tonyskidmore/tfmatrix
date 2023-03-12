#!/bin/bash
set -e

commit_updated_files=$(git diff-tree --no-commit-id --name-only "$GITHUB_SHA" -r)
echo "changed_files=$commit_updated_files" >> "$GITHUB_OUTPUT"
