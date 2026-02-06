#!/usr/bin/env bash
# Topic: JSON Processing with JQ
# File: 03-JSON-Processing-with-JQ/jq_parsing.sh

set -euo pipefail

# 1. Mock JSON Data (representing a Cloud Inventory)
INVENTORY='[
    {"id": "vm-01", "name": "web-server", "state": "running", "tags": ["prod", "web"]},
    {"id": "vm-02", "name": "db-server", "state": "stopped", "tags": ["prod", "db"]},
    {"id": "vm-03", "name": "dev-box", "state": "running", "tags": ["dev"]}
]'

echo "🔍 Analyzing Cloud Inventory..."

# 2. Extract specific counts
RUNNING_COUNT=$(echo "$INVENTORY" | jq '[.[] | select(.state == "running")] | length')
echo "  - Running Instances: $RUNNING_COUNT"

# 3. Filter and Format: Get names of PROD servers
echo -e "\n📦 Production Server IDs:"
echo "$INVENTORY" | jq -r '.[] | select(.tags[] | contains("prod")) | "  - \(.name) (\(.id))"'

# 4. Map-Reduce: Extract all unique tags
echo -e "\n🏷️  All Unique Infrastructure Tags:"
echo "$INVENTORY" | jq -r '[.[] | .tags[]] | unique | .[]' | sed 's/^/  - /'

# 5. Advanced: Create a new JSON report
echo -e "\n📊 Generating Minified JSON Report..."
echo "$INVENTORY" | jq -c '[.[] | {instance: .name, active: (.state == "running")}]'
