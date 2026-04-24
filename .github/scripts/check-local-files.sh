#!/bin/bash
# check-local-files.sh - Validates local file references in markdown files

set -euo pipefail

ERRORS=0
WARNINGS=0

echo "🔍 Checking local file references..."

# Find all markdown files
while IFS= read -r -d '' md_file; do
    # Extract local file references (images, links to .md, .sh, .py, .go files)
    grep -oP '\[.*?\]\(\K[^)]+(?=\))' "$md_file" 2>/dev/null | while read -r link; do
        # Skip external URLs
        if [[ "$link" =~ ^https?:// ]] || [[ "$link" =~ ^mailto: ]]; then
            continue
        fi
        
        # Skip anchors
        if [[ "$link" =~ ^# ]]; then
            continue
        fi
        
        # Calculate absolute path
        dir=$(dirname "$md_file")
        target="$dir/$link"
        
        # Normalize path
        target=$(realpath -m "$target" 2>/dev/null || echo "$target")
        
        # Check if file exists
        if [[ ! -e "$target" ]]; then
            echo "❌ BROKEN: $md_file -> $link"
            ((ERRORS++))
        fi
    done
done < <(find . -name "*.md" -not -path "./.git/*" -not -path "./node_modules/*" -print0)

# Check for deep nesting (more than 3 levels of ../)
echo ""
echo "🔍 Checking for deep nesting..."

while IFS= read -r -d '' md_file; do
    grep -oP '\[.*?\]\(\K[^)]+(?=\))' "$md_file" 2>/dev/null | while read -r link; do
        # Count ../ occurrences
        count=$(echo "$link" | grep -o '\.\.\/' | wc -l)
        
        if [[ $count -gt 3 ]]; then
            echo "⚠️  DEEP NESTING ($count levels): $md_file -> $link"
            ((WARNINGS++))
        fi
    done
done < <(find . -name "*.md" -not -path "./.git/*" -print0)

echo ""
echo "📊 Summary:"
echo "  Errors: $ERRORS"
echo "  Warnings: $WARNINGS"

if [[ $ERRORS -gt 0 ]]; then
    exit 1
fi

exit 0