#!/bin/bash
set -euo pipefail

URL="${1:-http://localhost:8080/health}"
TIMEOUT="${2:-5}"

echo "Checking $URL..."

if curl -sf --max-time "$TIMEOUT" "$URL" | jq -e '.status == "ok"' > /dev/null; then
    echo "Health check passed."
    exit 0
else
    echo "Health check failed."
    exit 1
fi

