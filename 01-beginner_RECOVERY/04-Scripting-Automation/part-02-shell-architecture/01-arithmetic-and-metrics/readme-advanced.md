# 🧮 Advanced Arithmetic: Metrics & Scalable Logic

While basic shells handle simple counters, professional DevOps automation requires high-precision calculations and bitwise optimizations for networking and resource pooling.

---

## 🔢 Integer Logic: The Native Engine

The double-parenthesis `(( ))` structure is the standard for high-speed integer arithmetic in Bash. It operates directly at the shell's memory level.

### 1. Assignment & Evaluative Forms

```bash
# Context A: Silent Assignment
(( COUNT = 10 * 5 ))

# Context B: Direct Increment/Decrement
(( RETRIES++ ))

# Context C: Evaluative (used in if/while)
if (( RESULT >= 100 )); then
    echo "Quota exceeded"
fi
```

### 2. Base Conversion (The Networking Pattern)

Bash can interpret numbers in different bases (2-64). This is essential for calculating subnet masks or hardware addresses.

```bash
# Convert Binary to Decimal
BINARY_VAL="2#1010"
echo $(( BINARY_VAL )) # Result: 10

# Convert Hex to Decimal
HEX_VAL="16#FF"
echo $(( HEX_VAL ))    # Result: 255
```

---

## 🌊 Floating Point Precision: The `bc` Protocol

Bash does not support decimal points natively. For cloud metrics (CPU load, Latency), you must delegate to the `bc` (Basic Calculator) engine.

### 1. The Scaling Formula

Without `scale`, `bc` defaults to integer division. Always specify precision for metrics.

```bash
# Result: 3.333
echo "scale=3; 10 / 3" | bc
```

### 2. High-Precision Conditionals
Because Bash cannot evaluate `[[ 0.5 -gt 0.1 ]]`, we use `bc` to return a boolean `1` or `0`.
```bash
CURRENT_LATENCY=0.455
MAX_LATENCY=0.500

# Pattern: Use -l to load the math library for advanced comparisons
if (( $(echo "$CURRENT_LATENCY < $MAX_LATENCY" | bc -l) )); then
    echo "Performance is within SLA."
fi
```

---

## 🚀 Professional Patterns: Bitwise Masking

Bitwise operations are used to manage "Bit Flags" (e.g., in high-performance logging levels) or calculating IP subnets.

```bash
# Scenario: Check if the 3rd bit (Value 4) is set in a status code
STATUS_CODE=7 # Binary 111
MASK=4       # Binary 100

if (( (STATUS_CODE & MASK) == MASK )); then
    echo "Feature Bit 3 is ACTIVE."
fi
```
