# 🧮 Input & Arithmetic

Bash is great at integer math, but notoriously tricky with floating-point numbers.

## 🔢 Integer Math: `(( ))`
The double parenthesis structure is the standard for integer arithmetic.

```bash
(( COUNT++ ))
RESULT=$(( A * B ))
```

---

## 🌊 Floating Point Math: `bc` (Basic Calculator)
Bash **cannot** do `1.5 + 1.5`. It treats them as strings. To handle decimals, percentages, or complex division, you must pipe to `bc`.

### Syntax
`echo "scale=2; OPERATION" | bc`

- `scale=2`: Tells `bc` how many decimal places to keep.

### Examples
```bash
# Division with decimals
echo "scale=2; 10 / 3" | bc
# Output: 3.33

# Comparison (returns 1 for True, 0 for False)
if (( $(echo "0.5 > 0.1" | bc -l) )); then
    echo "0.5 is greater"
fi
```

### ⚠️ Common Pitfalls
- Forgetting `scale`: `echo "10 / 3" | bc` outputs `3` (integer by default).
- Forgetting quote marks: `echo 1.5 > 2 | bc` will try to redirect to a file named `2`.
