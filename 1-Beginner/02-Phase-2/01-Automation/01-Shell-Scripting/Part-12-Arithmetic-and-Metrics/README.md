# 🔢 Arithmetic & Metrics: The Logic of Resource Calculation

> **"Arithmetic in Bash isn't just about math; it's about making decisions based on system resources, cost, and capacity."**

![Arithmetic & Metrics Banner](../assets/arithmetic_metrics_header.svg)

## 📚 Overview

In DevOps, you rarely calculate Fibonacci sequences, but you **frequently** calculate resources. Whether it's checking if disk usage > 90%, averaging CPU load over 5 minutes, or determining if you have enough RAM to launch a container, arithmetic is essential. This module covers the core mechanics of calculation, from legacy tools to modern floating-point precision.

### Historical Context & Evolution

Early Unix shells lacked built-in math capabilities, forcing engineers to spawn external processes like `expr` for even simple addition. This was slow and cumbersome. Modern Bash introduced the `$(( ... ))` arithmetic expansion, which is executed natively by the shell. For complex decimal math, we still integrate the `bc` (Basic Calculator) utility, bridging the gap between the shell's integer-only logic and the precise needs of metric monitoring.

---

## 💡 The "DevOps Why"

In high-scale environments, **Arithmetic is the foundation of Idempotency**.

- **Auto-scaling**: If (Target_Replica_Count - Current_Count) > 0, then launch instances.
- **Log Management**: If (Current_Log_Size / Max_Rotation_Size) > 0, then rotate logs.
- **Cost Control**: Calculate (Hourly_Instance_Cost * 24 * 30) before authorizing a stack deployment.

## 🎓 Learning Objectives

By the end of this module, you will:

1. ✅ **Master native integer math using `$(( ... ))`.**
   - **Why**: It's the fastest and most readable way to handle counters and basic capacity checks.
   - **Use Case**: Calculating the number of servers needed to handle a specific request volume.

2. ✅ **Leverage `bc` for floating-point (decimal) calculations.**
   - **Why**: Bash handles integers only; `bc` is required for precise metrics like CPU load averages.
   - **Use Case**: Triggering an alert if memory usage exceeds 85.5%.

3. ✅ **Implement assignment shorthands and increment/decrement patterns.**
   - **Why**: To write cleaner, more professional loop counters and accumulators.
   - **Use Case**: Tracking retry attempts in a connection loop using `((retries++))`.

4. ✅ **Understand Bitwise Operations for advanced system tasks.**
   - **Why**: Useful for manipulating file permissions or network masks.
   - **Use Case**: Calculating octal permissions for `chmod`.

5. ✅ **Construct a Metric Pipeline for infrastructure monitoring.**
   - **Why**: To automate the "Measure -> Calculate -> Act" workflow.
   - **Use Case**: Auto-scaling a cluster based on available RAM percentages.

---

## 🏗️ Evolution of Shell Math

Bash has built-in support for integer arithmetic, but it relies on external tools for floating-point math.

| Method | Syntax | Type | Speed | Status |
| :--- | :--- | :--- | :--- | :--- |
| **Double Parentheses** | `$(( 5 + 5 ))` | Integer | 🚀 Fast | **Preferred** (Modern Standard) |
| **Let Command** | `let "a = 5 + 5"` | Integer | ⚡ Fast | Good (Alternative) |
| **Expression Tool** | `expr 5 + 5` | Integer | 🐢 Slow | **Legacy** (Avoid) |
| **Basic Calculator** | `echo "5.5 + 2" &#124; bc` | Float | 🐢 Slow | **Essential** for component metrics |

### Common Pitfall: The Decimal Error

Bash will throw a syntax error if you attempt decimal math inside `$(( ... ))`.

```bash
# ❌ This will FAIL with a syntax error
result=$(( 10.5 + 2 ))

# ✅ Use bc for decimals
result=$(echo "10.5 + 2" | bc)
```

---

## 🚀 Professional Patterns for Automation

### Pattern A: The Accumulator Logic

When processing logs, you often need to sum values. Using `+=` is cleaner and more efficient.

```bash
total_errors=0
# ... inside a loop ...
(( total_errors += new_errors ))
```

### Pattern B: The Health Threshold check (Idempotent)

Avoid "flapping" alerts by calculating percentages before acting.

```bash
USED=80
TOTAL=100
# Calculate percentage
PERCENT=$(( (USED * 100) / TOTAL ))

if (( PERCENT > 90 )); then
    echo "🚨 CRITICAL: Disk at $PERCENT%"
fi
```

### Pattern C: Precision Scaling with `bc`

When using `bc`, you must explicitly set the `scale` variable (the number of decimal places) or your results will be truncated to integers.

```bash
# Calculate average load to 2 decimal places
# NOTE: scale only affects the result of division
AVG=$(echo "scale=2; 10.55 / 3" | bc)
echo "Average: $AVG" # Result: 3.51
```

### Pattern D: Mathematical Conditionals

Use the `$(echo "val1 > val2" | bc)` pattern for comparing decimals, which Bash cannot do natively.

```bash
THRESHOLD=0.9
CURRENT_LOAD=0.95

# bc returns 1 for true and 0 for false
if (( $(echo "$CURRENT_LOAD > $THRESHOLD" | bc -l) )); then
    echo "🚨 Performance degradation detected."
fi
```

---

## 🛠️ Code Boilerplates

### Standard: Simple Counter
Used for basic iteration or tracking successes in a batch job.

```bash
#!/bin/bash
counter=0
for item in ./*; do
    ((counter++))
done
echo "Processed $counter files."
```

### Production-Ready: Resource Threshold Monitor
Includes defensive checks (division by zero) and floating-point precision for metrics.

```bash
#!/usr/bin/env bash
set -euo pipefail

# Inputs: Used RAM, Total RAM (MB)
USED_RAM=1650
TOTAL_RAM=2048

# 1. Defensive Guard: Check for zero
if [[ $TOTAL_RAM -eq 0 ]]; then
    echo "Error: Total RAM cannot be zero." >&2
    exit 1
fi

# 2. Integer Math for basic check
PERCENT_INT=$(( (USED_RAM * 100) / TOTAL_RAM ))

# 3. Precision Math (using bc) for metrics
PERCENT_FLOAT=$(echo "scale=2; ($USED_RAM / $TOTAL_RAM) * 100" | bc)

echo "System Health Match:"
echo "- Raw Percent: ${PERCENT_INT}%"
echo "- High Precision: ${PERCENT_FLOAT}%"

if (( PERCENT_INT > 80 )); then
    echo "⚠️ ALERT: Memory pressure detected!"
fi
```

---

## 🔢 Operator Reference Table

### 2.1 Basic Arithmetic Operators

| Operator | Name | Description | Example | Result |
| :--- | :--- | :--- | :--- | :--- |
| `+` | Addition | Sums two values. | `$(( 10 + 2 ))` | `12` |
| `-` | Subtraction | Subtracts right from left. | `$(( 10 - 2 ))` | `8` |
| `*` | Multiplication | Multiplies values. | `$(( 10 * 2 ))` | `20` |
| `/` | Division | **Integer** division (truncates). | `$(( 10 / 3 ))` | `3` |
| `%` | Modulo | Returns the remainder. | `$(( 10 % 3 ))` | `1` |
| `**` | Exponentiation | Raises to power. | `$(( 2 ** 10 ))` | `1024` |

### 2.2 Assignment Shorthands ("Syntactic Sugar")

| Operator | Expands To | Description | Example (Given `a=10`) | New `a` |
| :--- | :--- | :--- | :--- | :--- |
| `+=` | `a = a + n` | Add and assign. | `(( a += 5 ))` | `15` |
| `-=` | `a = a - n` | Subtract and assign. | `(( a -= 3 ))` | `7` |
| `*=` | `a = a * n` | Multiply and assign. | `(( a *= 2 ))` | `20` |
| `/=` | `a = a / n` | Divide and assign. | `(( a /= 2 ))` | `5` |

### 2.3 Bitwise Operations (System Engineering)

Used for subnet calculations, flag masks, and performance-tuned logic.

| Operator | Name | Description | Example | Result |
| :--- | :--- | :--- | :--- | :--- |
| `<<` | Left Shift | Mult by power of 2. | `$(( 1 << 3 ))` | `8` |
| `>>` | Right Shift| Div by power of 2. | `$(( 8 >> 1 ))` | `4` |
| `&` | AND | Bitwise AND. | `$(( 5 & 3 ))` | `1` |
| `|` | OR | Bitwise OR. | `$(( 5 | 3 ))` | `7` |

---

## 🏆 Real-World DevOps Story: The Average Load Calamity

**The Scenario**: A script was supposed to monitor the Average CPU Load. The engineer used `(( AVG = LOAD / NODES ))`.
**The Discovery**: One day, the load was healthy but fractional (e.g., `0.9` across 2 nodes). Bash integer division calculated `0 / 2 = 0`. The monitoring system reported a "0% CPU utilization," which hid a critical process hang that was actually consuming 90% of a single node.
**The Fix**: They switched to `bc` with a scale of 2: `AVG=$(echo "scale=2; $LOAD / $NODES" | bc)`. This allowed the team to see the true fractional load and detect anomalies before they turned into outages.

---

## ❓ Interview Preparation (Arithmetic)

1. **Q: Does Bash support floating-point arithmetic natively?**
   * **A**: No. Bash only supports integer arithmetic. For floating-point operations, you must use external tools like `bc` or `awk`.
2. **Q: What is the difference between `i++` and `++i`?**
   * **A**: `i++` (postfix) returns the current value and then increments it. `++i` (prefix) increments the value first and then returns the new value.
3. **Q: How do you handle division by zero in Bash?**
   * **A**: Bash will throw a "division by 0" error and terminate the arithmetic expansion. Professional scripts should validate that the divisor is not zero before calculating.
4. **Q: What happens if you perform math on an undefined variable?**
   * **A**: In an arithmetic context, an undefined or empty variable is treated as `0`.

---

## 📝 Knowledge Check

1. **What is the result of `$(( 10 / 4 ))`?**
   * [ ] a) 2.5
   * [x] b) 2
   * [ ] c) 3
   * *Explanation: Bash performs integer division and truncates the decimal part.*

2. **Which command is used for decimal math in a pipeline?**
   * [ ] a) `expr`
   * [x] b) `bc`
   * [ ] c) `let`
   * *Explanation: `bc` (Basic Calculator) is the standard Unix utility for arbitrary-precision math.*

3. **What does `(( count %= 2 ))` do if count is 5?**
   * [x] a) Sets count to 1
   * [ ] b) Sets count to 2
   * [ ] c) Sets count to 10
   * *Explanation: `%` is the modulo operator. 5 divided by 2 has a remainder of 1.*

4. **True or False: `(( 5 > 2 ))` returns an exit status of 0 (success).**
   - [x] a) True
   - [ ] b) False
   - *Explanation: In arithmetic contexts, if the expression evaluates to non-zero (True), the exit status is 0.*

---

## 🔗 Next Steps

Ready to master the editor of the gods?

Proceed to: **[User Input](../Part-13-User-Input/README.md)** →
