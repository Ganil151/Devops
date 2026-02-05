#!/bin/bash 

set -euo pipefail

# Artifact Manager Script
ARTIFACT_DIR="artifacts/deploy-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$ARTIFACT_DIR"

cp -r src/ "$ARTIFACT_DIR/"

# Create checksum 
find "$ARTIFACT_DIR" -type f -exec md5sum {} \; > "$ARTIFACT_DIR/checksums.md5"

# Archive 
tar -czf "${ARTIFACT_DIR}.tar.gz" "$ARTIFACT_DIR"

# Cleanup
ls -t artifacts/*.tar.gz | tail -n +6 | xargs -r rm 

echo "Artifacts have been created and stored in ${ARTIFACT_DIR}.tar.gz"