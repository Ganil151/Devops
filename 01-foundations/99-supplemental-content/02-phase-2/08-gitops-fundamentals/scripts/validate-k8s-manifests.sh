#!/bin/bash
# K8s Manifest Validator

MANIFEST=${1:-"k8s/deployment.yaml"}

if [ ! -f "$MANIFEST" ]; then
    echo "Usage: ./validate-k8s-manifests.sh <file>"
    exit 1
fi

echo "Validating $MANIFEST..."

# Check 1: apiVersion
if ! grep -q "apiVersion:" "$MANIFEST"; then
    echo "[ERROR] Missing 'apiVersion'"
    exit 1
fi

# Check 2: kind
if ! grep -q "kind:" "$MANIFEST"; then
    echo "[ERROR] Missing 'kind'"
    exit 1
fi

# Check 3: metadata
if ! grep -q "metadata:" "$MANIFEST"; then
    echo "[ERROR] Missing 'metadata'"
    exit 1
fi

echo "[OK] Basic structure seems valid."
echo "(For full validation, use 'kubectl apply --dry-run=client -f $MANIFEST')"
