#!/bin/bash

set -e

# Cleanup function
cleanup() {
    if [ -n "$tmp_dir" ] && [ -d "$tmp_dir" ]; then
        echo "Cleaning up temporary directory..."
        rm -rf "$tmp_dir"
    fi
}

# Trap exit signals to ensure cleanup
trap cleanup EXIT

# Check if version argument is provided
if [ -z "$1" ]; then
    echo "Error: Version argument is required."
    echo "Usage: $0 <version>"
    echo "Example: $0 v0.1.3"
    echo ""
    echo "Current version in deployment: v0.1.2"
    exit 1
fi

new_ver=$1

echo "New version: $new_ver"

# Clone repo first to check current version
tmp_dir=$(mktemp -d)
echo "Created temporary directory: $tmp_dir"

git clone https://github.com/Ganil151/Argo-Project.git "$tmp_dir"

# Check deployment file
deployment_file="$tmp_dir/agrocd-lesson-1/my-app/deployment.yaml"

if [ ! -f "$deployment_file" ]; then
    echo "Error: Deployment file not found at $deployment_file"
    exit 1
fi

# Extract current version
current_ver=$(grep "image: ganil151/nginx" "$deployment_file" | sed 's/.*ganil151\/nginx[^:]*:\(.*\)/\1/' | tr -d ' ')

echo "Current version: $current_ver"

if [ "$current_ver" == "$new_ver" ]; then
    echo "Already at version $new_ver. No changes needed."
    exit 0
fi

# Proceed with docker operations
echo "Tagging docker image..."
docker tag nginx:1.29.4 ganil151/nginx:"$new_ver"

echo "Pushing docker image..."
docker push ganil151/nginx:"$new_ver"

# Update image tag - use correct sed syntax for Linux (no empty string after -i)
echo "Updating deployment file..."
sed -i "s|ganil151/nginx[^:]*:.*|ganil151/nginx:$new_ver|g" "$deployment_file"

# Commit and push
cd "$tmp_dir"
git add .
git commit -m "Update nginx image to version $new_ver"
git push origin main

echo "Upgrade completed successfully!"
