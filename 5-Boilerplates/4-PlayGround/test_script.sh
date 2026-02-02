#!/bin/bash

# Test script to verify the logging fix works correctly

echo "Testing the enhanced block_popups.sh script..."
echo ""

# Test 1: Help command (should work without sudo)
echo "Test 1: Running --help (should work without errors)"
./block_popups.sh --help > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Help command works"
else
    echo "✗ Help command failed"
fi
echo ""

# Test 2: Check if script detects non-root execution
echo "Test 2: Running without sudo (should show error message)"
./block_popups.sh 2>&1 | grep -q "must be run as root"
if [ $? -eq 0 ]; then
    echo "✓ Root check works correctly"
else
    echo "✗ Root check failed"
fi
echo ""

# Test 3: Verify script syntax
echo "Test 3: Checking script syntax"
bash -n ./block_popups.sh
if [ $? -eq 0 ]; then
    echo "✓ Script syntax is valid"
else
    echo "✗ Script has syntax errors"
fi
echo ""

# Test 4: Check if log directory auto-creation works
echo "Test 4: Verifying log directory auto-creation"
# Run help which triggers logging
./block_popups.sh --help > /dev/null 2>&1
if [ -d "/var/log/browser-security" ]; then
    echo "✓ Log directory created automatically"
    ls -ld /var/log/browser-security
else
    echo "⚠ Log directory not created (may need sudo)"
fi
echo ""

echo "================================================================================"
echo "All tests completed!"
echo ""
echo "To run the actual security hardening:"
echo "  sudo ./block_popups.sh"
echo ""
echo "To view the quick reference:"
echo "  ./QUICK_REFERENCE.sh"
echo "================================================================================"
