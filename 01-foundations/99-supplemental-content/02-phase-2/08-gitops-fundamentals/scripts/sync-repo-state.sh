#!/bin/bash
# GitOps Sync Checker
# Checks if local repo matches remote

echo "Checking Git Sync Status..."

git fetch origin main > /dev/null 2>&1

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

echo "Local:  $LOCAL"
echo "Remote: $REMOTE"

if [ "$LOCAL" == "$REMOTE" ]; then
    echo -e "\n[OK] Repository is in sync."
else
    echo -e "\n[WARN] Repository is out of sync!"
    echo "You may need to pull changes or push commits."
    exit 1
fi
