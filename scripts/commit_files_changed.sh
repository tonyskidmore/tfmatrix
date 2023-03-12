#!/bin/bash
set -ex

git diff-tree --no-commit-id --name-only "$GITHUB_SHA" -r
