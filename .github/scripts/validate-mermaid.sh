#!/bin/bash
# validate-mermaid.sh - Validates Mermaid diagram syntax

set -euo pipefail

ERRORS=0

echo "📊 Validating Mermaid diagrams..."

for md_file in "$@"; do
    echo "Checking: $md_file"
    
    # Extract Mermaid code blocks
    awk '/```mermaid/,/```/ {if (!/```/) print}' "$md_file" > /tmp/mermaid_temp.mmd 2>/dev/null || continue
    
    if [[ -s /tmp/mermaid_temp.mmd ]]; then
        # Try to compile with mmdc (if available)
        if command -v mmdc &> /dev/null; then
            if ! mmdc -i /tmp/mermaid_temp.mmd -o /tmp/mermaid_test.svg 2>/dev/null; then
                echo "  ❌ Invalid Mermaid syntax"
                ((ERRORS++))
            else
                echo "  ✅ Valid Mermaid diagram"
            fi
        else
            # Basic syntax check
            if grep -q "graph\|flowchart\|sequenceDiagram\|classDiagram\|stateDiagram\|erDiagram\|gantt\|pie" /tmp/mermaid_temp.mmd; then
                echo "  ✅ Mermaid diagram found (syntax not validated)"
            else
                echo "  ⚠️  Mermaid block found but no diagram type detected"
            fi
        fi
    fi
    
    rm -f /tmp/mermaid_temp.mmd /tmp/mermaid_test.svg
done

echo ""
echo "📊 Summary:"
echo "  Errors: $ERRORS"

if [[ $ERRORS -gt 0 ]]; then
    exit 1
fi

exit 0