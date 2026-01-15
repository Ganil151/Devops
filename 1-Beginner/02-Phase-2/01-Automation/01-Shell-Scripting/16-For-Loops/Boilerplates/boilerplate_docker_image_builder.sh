#!/bin/bash

# boilerplate_docker_image_builder.sh - Multi-platform image builder

set -euo pipefail

readonly IMAGE_NAME="myapp"
readonly TAG="latest"
readonly PLATFORMS=("linux/amd64" "linux/arm64")

for platform in "${PLATFORMS[@]}"; do
    arch=$(echo "$platform" | cut -d'/' -f2)
    
    echo "Building for $platform..."
    docker buildx build \
        --platform "$platform" \
        -t "${IMAGE_NAME}:${TAG}-${arch}" \
        --load \
        .
    
    echo "✓ Built: ${IMAGE_NAME}:${TAG}-${arch}"
done

# Create manifest
docker manifest create "${IMAGE_NAME}:${TAG}" \
    "${IMAGE_NAME}:${TAG}-amd64" \
    "${IMAGE_NAME}:${TAG}-arm64"

echo "✓ Multi-platform build complete"
