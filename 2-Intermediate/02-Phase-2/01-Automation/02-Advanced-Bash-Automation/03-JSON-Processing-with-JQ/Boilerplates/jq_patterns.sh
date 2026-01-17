#!/bin/bash
# -----------------------------------------------------------------------------
# Name: jq_patterns.sh
# Description: Demonstrates robust JSON processing with jq.
# -----------------------------------------------------------------------------

set -euo pipefail

# Mock JSON Data strings for demonstration
JSON_DATA='{
  "instances": [
    { "id": "i-123", "state": "running", "tags": { "Name": "web-01" } },
    { "id": "i-456", "state": "stopped", "tags": {} },
    { "id": "i-789", "state": "running", "tags": { "Name": "db-01" } }
  ]
}'

echo "--- 1. Simple Extraction (.id) ---"
echo "$JSON_DATA" | jq -r '.instances[0].id'

echo ""
echo "--- 2. Iterate and Filter (running instances) ---"
echo "$JSON_DATA" | jq -r '.instances[] | select(.state == "running") | .id'

echo ""
echo "--- 3. Handling Nulls with Defaults (//) ---"
# Instance i-456 has empty tags. The Name will be null.
echo "$JSON_DATA" | jq -r '.instances[] | "\(.id): \(.tags.Name // "NO_NAME")"'

echo ""
echo "--- 4. Object Construction ---"
echo "$JSON_DATA" | jq -c '.instances[] | {instance_id: .id, status: .state}'
