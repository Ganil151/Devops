#!/bin/bash
# -----------------------------------------------------------------------------
# Name: scan_repo.sh
# Description: Automating secret detection in Git repositories.
# -----------------------------------------------------------------------------

REPO_PATH="${1:-.}"

echo "LOG: Starting TruffleHog scan on $REPO_PATH..."

# 1. Scan the entire git history
trufflehog git file://"$REPO_PATH" --fail

# 2. To scan just the filesystem (without git history)
# trufflehog filesystem "$REPO_PATH" --fail

# 3. To scan a remote GitHub repo
# trufflehog github --repo https://github.com/user/project --fail

if [[ $? -eq 0 ]]; then
    echo "SUCCESS: No secrets found."
else
    echo "ERROR: Secrets detected! Check the output above."
    exit 1
fi
