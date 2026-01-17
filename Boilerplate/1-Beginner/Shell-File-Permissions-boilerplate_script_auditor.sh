#!/bin/bash

# boilerplate_script_auditor.sh - Security compliance audit

find . -type f -name "*.sh" -perm -002 | while read file; do
    echo "❌ INSECURE: $file (world-writable)"
done

find . -type f -name "*.sh" ! -perm -u+x | while read file; do
    echo "⚠ NOT EXECUTABLE: $file"
done

echo "✓ Security audit complete"
