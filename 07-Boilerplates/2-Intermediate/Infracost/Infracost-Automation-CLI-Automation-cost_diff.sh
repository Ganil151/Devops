#!/bin/bash
# -----------------------------------------------------------------------------
# Name: cost_diff.sh
# Description: Automates the comparison of two infrastructure states.
# -----------------------------------------------------------------------------

set -e

# Configuration
BASE_JSON="/tmp/base_cost.json"
PR_DIR="./terraform"

echo "LOG: Generating cost breakdown for current directory..."
infracost breakdown --path "$PR_DIR" \
                    --format json \
                    --out-file current_cost.json

if [[ -f "$BASE_JSON" ]]; then
    echo "LOG: Found base cost file. Generating diff report..."
    infracost diff --path current_cost.json \
                  --compare-to "$BASE_JSON" \
                  --format table
else
    echo "WARNING: No base cost file found at $BASE_JSON."
    echo "To set a baseline, run: infracost breakdown --path . --format json --out-file $BASE_JSON"
fi
