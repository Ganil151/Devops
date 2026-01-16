#!/bin/bash
# validate-exercises.sh - Validates exercise file structure

set -euo pipefail

ERRORS=0

echo "📚 Validating exercise structure..."

# Find all EXERCISES.md files
while IFS= read -r -d '' exercise_file; do
    echo "Checking: $exercise_file"
    
    # Check for required sections
    if ! grep -q "## 🟢 \*\*BEGINNER EXERCISES" "$exercise_file"; then
        echo "  ❌ Missing BEGINNER EXERCISES section"
        ((ERRORS++))
    fi
    
    if ! grep -q "## 🟡 \*\*INTERMEDIATE EXERCISES" "$exercise_file"; then
        echo "  ⚠️  Missing INTERMEDIATE EXERCISES section (optional)"
    fi
    
    if ! grep -q "Expected Output" "$exercise_file"; then
        echo "  ❌ Missing Expected Output sections"
        ((ERRORS++))
    fi
    
    if ! grep -q "Real-World Application" "$exercise_file"; then
        echo "  ❌ Missing Real-World Application sections"
        ((ERRORS++))
    fi
    
    # Count exercises (should have 10)
    exercise_count=$(grep -c "^### \*\*Exercise [0-9]" "$exercise_file" || echo "0")
    if [[ $exercise_count -lt 10 ]]; then
        echo "  ⚠️  Only $exercise_count exercises found (expected 10)"
    fi
    
done < <(find . -name "EXERCISES.md" -not -path "./.git/*" -print0)

echo ""
echo "📊 Summary:"
echo "  Errors: $ERRORS"

if [[ $ERRORS -gt 0 ]]; then
    exit 1
fi

exit 0