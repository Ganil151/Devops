#!/bin/bash

# This script ensures Docker BuildX is installed and creates/starts a reliable
# builder instance to prevent "inactive" status errors during docker-compose build.

set -e

# --- Configuration ---
# Use a recent BuildX version (v0.14.0 meets the compatibility requirement)
BUILDX_VERSION="v0.29.0"
BUILDX_DOWNLOAD_URL="https://github.com/docker/buildx/releases/download/${BUILDX_VERSION}/buildx-${BUILDX_VERSION}.linux-amd64"
DOCKER_CLI_PLUGINS_DIR="/usr/local/lib/docker/cli-plugins"
BUILDX_PATH="${DOCKER_CLI_PLUGINS_DIR}/docker-buildx"
BUILDER_NAME="jenkins-builder"

echo "Starting Docker BuildX fix script..."

# --- 1. Install or Update BuildX Binary ---
echo "Checking and installing Docker BuildX ${BUILDX_VERSION}..."

# Check if the correct version is installed before attempting to download/move
if ! docker buildx version 2>&1 | grep -q "${BUILDX_VERSION}"; then
    echo "Installing Docker BuildX binary..."
    
    # Ensure the plugins directory exists
    sudo mkdir -p ${DOCKER_CLI_PLUGINS_DIR}
    
    # Download binary
    curl -SL $BUILDX_DOWNLOAD_URL -o docker-buildx-temp
    
    # Move and set permissions in the system plugins directory
    sudo mv docker-buildx-temp $BUILDX_PATH
    sudo chmod +x $BUILDX_PATH
    
    echo "BuildX binary installed successfully."
else
    echo "BuildX binary is already installed."
fi

# --- 2. Configure and Bootstrap Builder Instance ---
echo "Configuring and bootstrapping the Docker BuildX builder..."

# Remove potentially stale or inactive builders (ignore errors if they don't exist)
docker buildx rm ${BUILDER_NAME} 2>/dev/null || true
docker buildx rm musing_kare 2>/dev/null || true

# Create a new, reliable builder instance using the container driver, 
# and set it as the default for subsequent 'docker build' commands.
echo "Creating new builder: ${BUILDER_NAME}"
docker buildx create \
    --name ${BUILDER_NAME} \
    --use \
    --driver docker-container

# Start/Bootstrap the builder node to ensure its container is running and active
echo "Bootstrapping builder node to ensure it is running..."
docker buildx inspect ${BUILDER_NAME} --bootstrap

echo "--- Final BuildX Status Check ---"
docker buildx inspect ${BUILDER_NAME}

echo "Docker BuildX setup is now complete and active."