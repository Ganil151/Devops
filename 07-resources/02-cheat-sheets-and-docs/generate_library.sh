#!/bin/bash

# ==============================================================================
# Script Name: generate_library.sh
# Description: Generates the standard DevOps Cheatsheet Library structure.
#              Creates categories and initializes markdown files.
# ==============================================================================

BASE_DIR="/home/gsmash/Documents/Devops/09-resources/00-cheatsheets"
mkdir -p "$BASE_DIR"

# Define the Core Curriculum Categories
CATEGORIES=(
    "01-linux-bash-mastery"
    "02-git-collaboration"
    "03-python-boto3-automation"
    "04-aws-networking-security"
    "05-terraform-iac"
    "06-docker-containers"
    "07-kubernetes-k8s"
    "08-cicd-pipelines"
)

echo "🚀 Initializing DevOps Resource Library at: $BASE_DIR"

for category in "${CATEGORIES[@]}"; do
    target_dir="$BASE_DIR/$category"
    mkdir -p "$target_dir"
    
    # Initialize cheatsheet.md with H1 header if it doesn't exist
    if [[ ! -f "$target_dir/cheatsheet.md" ]]; then
        echo "# $category" > "$target_dir/cheatsheet.md"
        echo "  - Created: $category/cheatsheet.md"
    else
        echo "  - Exists:  $category/cheatsheet.md"
    fi
done

echo "✅ Library generation complete."