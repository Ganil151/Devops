#!/bin/bash
# check-images.sh - Validates image references in markdown files

set -euo pipefail

ERRORS=0
MISSING_IMAGES=()

echo "🖼️  Checking image references..."

# Find all markdown files
while IFS= read -r -d '' md_file; do
    # Extract image references
    grep -oP '!\[.*?\]\(\K[^)]+(?=\))' "$md_file" 2>/dev/null | while read -r img; do
        # Skip external URLs
        if [[ "$img" =~ ^https?:// ]]; then
            continue
        fi
        
        # Calculate absolute path
        dir=$(dirname "$md_file")
        target="$dir/$img"
        
        # Normalize path
        target=$(realpath -m "$target" 2>/dev/null || echo "$target")
        
        # Check if image exists
        if [[ ! -e "$target" ]]; then
            echo "❌ MISSING IMAGE: $md_file -> $img"
            MISSING_IMAGES+=("$img")
            ((ERRORS++))
        fi
    done
done < <(find . -name "*.md" -not -path "./.git/*" -not -path "./node_modules/*" -print0)

echo ""
echo "📊 Summary:"
echo "  Missing images: $ERRORS"

if [[ $ERRORS -gt 0 ]]; then
    echo ""
    echo "📝 Missing images list:"
    printf '%s\n' "${MISSING_IMAGES[@]}" | sort -u
fi

exit 0  # Don't fail build for missing images, just report