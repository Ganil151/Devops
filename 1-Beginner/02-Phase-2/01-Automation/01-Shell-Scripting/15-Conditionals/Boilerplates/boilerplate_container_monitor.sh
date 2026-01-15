#!/bin/bash

# boilerplate_container_monitor.sh - Service recovery automation

set -euo pipefail

readonly CONTAINER_NAME="${1:-myapp}"

if docker ps | grep -q "$CONTAINER_NAME"; then
    echo "✓ Container $CONTAINER_NAME is running"
else
    echo "⚠️  Container $CONTAINER_NAME is not running. Starting..."
    docker start "$CONTAINER_NAME" || docker run -d --name "$CONTAINER_NAME" myapp:latest
    echo "✓ Container started"
fi
