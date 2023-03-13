#!/bin/bash
set -e

commit_updated_files=$(git diff-tree --no-commit-id --name-only "$GITHUB_SHA" -r)

# How to fix or avoid Error: Unable to process file command 'output' successfully?
# https://stackoverflow.com/questions/74137120/how-to-fix-or-avoid-error-unable-to-process-file-command-output-successfully
# https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#multiline-strings
EOF=$(dd if=/dev/urandom bs=15 count=1 status=none | base64)

echo "changed_files<<$EOF" >> $GITHUB_OUTPUT
echo "$commit_updated_files" >> $GITHUB_OUTPUT
echo "$EOF" >> $GITHUB_OUTPUT


echo "commit_updated_files: $commit_updated_files"

# if [[ -n "$commit_updated_files" ]]
# then
#   echo "changed_files=$commit_updated_files" >> "$GITHUB_OUTPUT"
# else
#   echo "changed_files='none'" >> "$GITHUB_OUTPUT"
# fi
