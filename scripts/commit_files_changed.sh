#!/bin/bash
set -e

changed_files=$(git diff-tree --no-commit-id --name-only "$GITHUB_SHA" -r)
echo "changed_files=${changed_files}" >> "$GITHUB_OUTPUT"
