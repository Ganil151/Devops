#!/bin/bash
# Permission Enforcer
# Sets 644 on files and 755 on dirs recursively.

DIR=${1:-"."}

echo "Enforcing standard permissions on $DIR..."

# Directories -> 755
find "$DIR" -type d -exec chmod 755 {} +
echo "Directories set to 755."

# Files -> 644
find "$DIR" -type f -exec chmod 644 {} +
echo "Files set to 644."

# Executables (optional - user prompt)
read -p "Are there scripts/binaries to fix? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter extension (e.g. .sh): " EXT
    find "$DIR" -name "*$EXT" -exec chmod +x {} +
    echo "Added +x to *$EXT"
fi

echo "Done."
