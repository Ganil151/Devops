#!/usr/bin/env bash
# Topic: Infracost CLI Automation
# Description: Generates a cost diff and outputs a summary for CI/CD logging.

set -euo pipefail

TF_DIR="./terraform"
REPORT_DIR="./cost_reports"
mkdir -p "$REPORT_DIR"

echo "🔍 Starting Infracost Analysis..."

# 1. Generate Baseline (In real CI, this would be from the 'main' branch)
infracost breakdown --path "$TF_DIR" \
                    --format json \
                    --out-file "$REPORT_DIR/base.json"

# 2. Generate Current State (The PR / Current Branch)
# We use 'diff' to see the delta
infracost diff --path "$TF_DIR" \
               --compare-to "$REPORT_DIR/base.json" \
               --format json \
               --out-file "$REPORT_DIR/diff.json"

# 3. Output Human-Readable Summary to Console
echo "------------------------------------------------"
echo "💰 COST IMPACT SUMMARY"
echo "------------------------------------------------"
infracost output --path "$REPORT_DIR/diff.json" --format table

# 4. Success Check
echo "✅ Cost analysis complete. Report saved to $REPORT_DIR/diff.json"
