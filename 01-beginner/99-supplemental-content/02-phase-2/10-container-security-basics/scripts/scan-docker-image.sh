#!/bin/bash
# Docker Image Scanner (Mock Wrapper)

IMAGE=$1

if [ -z "$IMAGE" ]; then
    echo "Usage: $0 <image-name>"
    exit 1
fi

echo "Scanning $IMAGE for vulnerabilities..."

# Check for Trivy
if command -v trivy &> /dev/null; then
    trivy image "$IMAGE"
else
    echo "Trivy not found. Running basic checks..."
    
    # Basic Check: Root User
    USER=$(docker image inspect "$IMAGE" --format='{{.Config.User}}')
    if [ -z "$USER" ] || [ "$USER" == "0" ] || [ "$USER" == "root" ]; then
        echo "[WARN] Image runs as ROOT."
    else
        echo "[OK] Image runs as user: $USER"
    fi
    
    echo "Install 'trivy' for full vulnerability scanning."
fi
