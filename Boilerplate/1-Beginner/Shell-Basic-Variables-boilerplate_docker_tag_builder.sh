#!/bin/bash

# boilerplate_docker_tag_builder.sh - Image versioning

set -euo pipefail

readonly BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
readonly COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "latest")
readonly BUILD_NUMBER="${BUILD_NUMBER:-local}"

# Generate tags
readonly TAG_COMMIT="${BRANCH}-${COMMIT}"
readonly TAG_BUILD="${BRANCH}-build${BUILD_NUMBER}"
readonly TAG_LATEST="${BRANCH}-latest"

echo "Docker Image Tags:"
echo "  - Commit: ${TAG_COMMIT}"
echo "  - Build: ${TAG_BUILD}"
echo "  - Latest: ${TAG_LATEST}"

# Export for Docker build
export DOCKER_TAG_COMMIT="$TAG_COMMIT"
export DOCKER_TAG_BUILD="$TAG_BUILD"
export DOCKER_TAG_LATEST="$TAG_LATEST"
