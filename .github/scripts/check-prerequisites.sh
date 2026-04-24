#!/bin/bash
# check-prerequisites.sh - Validates prerequisite links in README files

set -euo pipefail

ERRORS=0

echo "🔗 Checking prerequisite links..."

# Find all README files
while IFS= read -r -d '' readme_file; do
    # Check if file has Prerequisites section
    if grep -q "## Prerequisites" "$readme_file" || grep -q "### Prerequisites" "$readme_file"; then
        # Extract links from Prerequisites section
        awk '/## Prerequisites/,/^##/ {print}' "$readme_file" | \
        grep -oP '\[.*?\]\(\K[^)]+(?=\))' 2>/dev/null | while read -r link; do
            # Skip external URLs and anchors
            if [[ "$link" =~ ^https?:// ]] || [[ "$link" =~ ^# ]]; then
                continue
            fi
            
            # Calculate absolute path
            dir=$(dirname "$readme_file")
            target="$dir/$link"
            target=$(realpath -m "$target" 2>/dev/null || echo "$target")
            
            # Check if target exists
            if [[ ! -e "$target" ]]; then
                echo "❌ BROKEN PREREQUISITE: $readme_file -> $link"
                ((ERRORS++))
            fi
        done
    fi
done < <(find . -name "README.md" -not -path "./.git/*" -print0)

echo ""
echo "📊 Summary:"
echo "  Broken prerequisite links: $ERRORS"

if [[ $ERRORS -gt 0 ]]; then
    exit 1
fi

exit 0