#!/bin/bash
# ==============================================================================
# Script Name: operators.sh
# Author:      Ganil
# Description: Demonstrates basic arithmetic operators using legacy 'expr'.
# Study Link:  https://tldp.org/LDP/abs/html/ops.html
# ==============================================================================

# Initialize variables
var1=30
var2=20

echo "🔢 Initial Values: var1=$var1, var2=$var2"
echo "----------------------------------------"

# 1. Addition (+)
# Note: expr requires spaces around the operator
sum=$(expr $var1 + $var2)
echo "➕ Addition ($var1 + $var2): $sum"

# 2. Subtraction (-)
sub=$(expr $var1 - $var2)
echo "➖ Subtraction ($var1 - $var2): $sub"

# 3. Multiplication (*)
# Note: The asterisk must be escaped (*) to avoid shell globbing
mul=$(expr $var1 \* $var2)
echo "✖️ Multiplication ($var1 * $var2): $mul"

# 4. Division (/)
# Note: expr performs integer division only (no decimals)
div=$(expr $var1 / $var2)
echo "➗ Division ($var1 / $var2): $div (Integer Result)"

# 5. Modulo (%)
# Returns the remainder
mod=$(expr $var1 % $var2)
echo "remainder Modulo ($var1 % $var2): $mod"

echo "----------------------------------------"
echo "✅ Operational Demonstration Complete."
