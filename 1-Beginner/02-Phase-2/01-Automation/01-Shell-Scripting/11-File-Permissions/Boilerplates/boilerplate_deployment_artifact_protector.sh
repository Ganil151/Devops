#!/bin/bash

# boilerplate_deployment_artifact_protector.sh  - Immutable release artifacts

readonly ARTIFACT_DIR="${1:-./dist}"

find "$ARTIFACT_DIR" -type f \( -name "*.jar" -o -name "*.war" -o -name "*.zip" \) | while read artifact; do
    chmod 444 "$artifact"
    echo "✓ Protected: $artifact (r--r--r--)"
done

echo "Release artifacts protected!"
