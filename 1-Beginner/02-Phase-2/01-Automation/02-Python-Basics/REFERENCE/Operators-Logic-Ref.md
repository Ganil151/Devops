# Python Operators & Computational Logic

> **"Operators are the 'engine' of automation logic. Without mastering them, a DevOps engineer cannot build effective conditional pipelines or resource-monitoring scripts."**

Mastering Python operators is not just about doing math; it's about defining the decision-making boundaries of your infrastructure. Whether you are comparing CPU thresholds, validating complex cloud resource identities, or handling binary-level flags for advanced network protocols, your ability to script logic depends on these fundamental symbols.

---

## 1. Arithmetic Operators (Basic Computation)

**DEFINITION**
Arithmetic operators are used with numeric values to perform common mathematical operations. Python handles these at a high-level, supporting both integers and floats dynamically.

- `+` (Addition)
- `-` (Subtraction)
- `*` (Multiplication)
- `/` (Division) - Always returns a float.
- `//` (Floor Division) - Returns the largest integer less than or equal to the result.
- `%` (Modulus) - Returns the remainder of the division.
- `**` (Exponentiation) - Raises a number to the power of another.

**[WHY FOR DEVOPS]**  
Calculating resource utilization, availability percentages, and predictive scaling (e.g., doubling the current instance count) requires precise arithmetic.

**[CODE EXAMPLE]**
```python
# Calculating Disk Usage Percentage
total_disk_gb: int = 500
used_disk_gb: int = 150

usage_ratio: float = used_disk_gb / total_disk_gb
usage_percent: float = usage_ratio * 100

print(f"Current Disk Usage: {usage_percent}%")

# Calculating remaining storage using modulus (e.g., for chunked backups)
remaining_blocks: int = 1025 % 512
print(f"Residual data block size: {remaining_blocks} bytes")
```

---

## 2. Assignment Operators (State Persistence)

**[DEFINITION]**  
Assignment operators are used to assign values to variables. Compound assignment operators (like `+=`) perform an operation and then assign the result to the variable in a single step, which is more efficient for the interpreter.

**[WHY FOR DEVOPS]**  
Essential for managing loops, retry counters in CI/CD pipelines, and accumulating resource metrics (e.g., Total Latency across 10 API calls).

**[CODE EXAMPLE]**
```python
# CI/CD Retry Counter
retry_count: int = 0
MAX_RETRIES: int = 3

while retry_count < MAX_RETRIES:
    print(f"Attempting deployment... Attempt {retry_count + 1}")
    # Simulate a failed attempt
    retry_count += 1  # Equivalent to retry_count = retry_count + 1

print(f"Final retry state: {retry_count}")
```

---

## 3. Relational / Comparison Operators (Decision Boundaries)

**[DEFINITION]**  
Comparison operators compare two values and return a Boolean (`True` or `False`).

- `==` (Equal)
- `!=` (Not equal)
- `>` (Greater than)
- `<` (Less than)
- `>=` (Greater than or equal to)
- `<=` (Less than or equal to)

**[WHY FOR DEVOPS]**  
Threshold monitoring is the backbone of observability. If `current_cpu > high_cpu_threshold`, trigger an alert or scale-out event.

**[CODE EXAMPLE]**  
```python
# Monitoring Thresholds
current_cpu_usage: float = 85.5
CRITICAL_THRESHOLD: float = 80.0

if current_cpu_usage >= CRITICAL_THRESHOLD:
    print(f"ALERT: CPU Usage {current_cpu_usage}% exceeds {CRITICAL_THRESHOLD}%!")
else:
    print("Health Check: CPU usage within normal limits.")
```

> **Curriculum Link**: To see how these operators drive decision-making in real-world automation, proceed to: **[02-Control-Flow](../1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/02-Control-Flow/README.md)**

---

## 4. Logical Operators (Multi-Condition Logic)

**[DEFINITION]**  
Logical operators combine conditional statements. Python implements **Short-circuit evaluation**, where the second argument is only executed if the first argument does not suffice to determine the result of the expression.

- `and`: Returns `True` if both statements are true. (Short-circuits if the first is `False`)
- `or`: Returns `True` if one of the statements is true. (Short-circuits if the first is `True`)
- `not`: Reverses the result (True becomes False).

**[WHY FOR DEVOPS]**  
Validating complex states. For example: "Only deploy if the environment is 'staging' AND the health-check is 'passing'."

**[CODE EXAMPLE]**
```python
# Multi-conditional Deployment Guard
server_is_online: bool = True
health_check_status: str = "passing"
environment: str = "production"

# Use logical operators to combine checks
if server_is_online and health_check_status == "passing":
    print("Pre-flight checks successful. Proceeding with deployment.")

# Short-circuit safety checking (preventing NoneType errors)
config_map = None
# This will NOT raise an error because 'config_map is not None' is False, so 'config_map["key"]' is never evaluated.
if config_map is not None and "debug" in config_map:
    print("Debug mode enabled")
```

---

## 5. Identity Operators (Memory vs. Value)

**[DEFINITION]**  
Identity operators compare the objects, not for equality, but to see if they are actually the same object, with the same memory location.

- `is`: Returns `True` if both variables point to the same object.
- `is not`: Returns `True` if both variables point to different objects.

**[WHY FOR DEVOPS]**  
In DevOps automation, using `is` to compare string values can lead to false negatives because `is` checks the memory address (`id()`), whereas `==` checks the value. Use `is` primarily for checking against `None`.

**[CODE EXAMPLE]**
```python
# The 'is' vs '==' Trap
list_a: list[str] = ["web-01", "web-02"]
list_b: list[str] = ["web-01", "web-02"]

print(f"Equality Check (list_a == list_b): {list_a == list_b}")  # True - Values are the same
print(f"Identity Check (list_a is list_b): {list_a is list_b}")  # False - Different memory addresses

# Correct use case: Checking for None
db_connection = None
if db_connection is None:
    print("Initializing connection pool...")
```

---

## 6. Membership Operators (Collection Queries)

**[DEFINITION]**  
Membership operators are used to test if a sequence (string, list, tuple, etc.) is present in an object.

- `in`: Returns `True` if a sequence with the specified value is present in the object.
- `not in`: Returns `True` if a sequence with the specified value is not present in the object.

**[WHY FOR DEVOPS]**  
Validating IPs in a whitelist, checking for forbidden keywords in log streams, or seeing if a specific flag exists in a CLI argument list.

**[CODE EXAMPLE]**
```python
# Whitelist Validation
allowed_ips: list[str] = ["10.0.0.1", "10.0.0.2", "192.168.1.50"]
incoming_ip: str = "10.0.0.5"

if incoming_ip not in allowed_ips:
    print(f"SECURITY ALERT: Unauthorized access attempt from {incoming_ip}")

# Log Scraping
log_line: str = "2026-01-20 10:42:01 [CRITICAL] Memory leak detected in worker-04"
if "CRITICAL" in log_line:
    print("Dispatching P0 Incident Bridge...")
```

---

## 7. Bitwise Operators (Binary-Level Flags)

**[DEFINITION]**  
Bitwise operators are used to compare (binary) numbers. They are rare in high-level scripting but essential for low-level system interactions.

- `&` (AND): Sets each bit to 1 if both bits are 1.
- `|` (OR): Sets each bit to 1 if one of two bits is 1.
- `^` (XOR): Sets each bit to 1 if only one of two bits is 1.
- `~` (NOT): Inverts all the bits.
- `<<` (Left shift): Push zeros in from the right and let the leftmost bits fall off.
- `>>` (Right shift): Push copies of the leftmost bit in from the left, and let the rightmost bits fall off.

**[WHY FOR DEVOPS]**  
Handling Linux file permissions (Octal), network subnet calculations (CIDR masks), or parsing binary flags from hardware/network device responses.

**[CODE EXAMPLE]**
```python
# Simulating Linux Permission Checks (Octal)
# Read = 4 (100), Write = 2 (010), Execute = 1 (001)
READ_BIT: int = 0b100
WRITE_BIT: int = 0b010

# User has Read and Write (6 or 110)
current_perms: int = 0b110

# Check if user has write access using bitwise AND
has_write: bool = (current_perms & WRITE_BIT) != 0
print(f"Has write access: {has_write}")
```

---

## 8. Precedence of Operations (The Order of Logic)

**[DEFINITION]**  
The order in which Python evaluates expressions. If you don't use parentheses, Python follows these rules.

| Level | Operator                                                         | Description                                       |            |
| :---- | :--------------------------------------------------------------- | :------------------------------------------------ | ---------- |
| 1     | `()`                                                             | Parentheses (Grouping)                            |            |
| 2     | `**`                                                             | Exponentiation                                    |            |
| 3     | `+x`, `-x`, `~x`                                                 | Unary Plus, Minus, bitwise NOT                    |            |
| 4     | `*`, `/`, `//`, `%`                                              | Multiplication, Division, Floor division, Modulus |            |
| 5     | `+`, `-`                                                         | Addition, Subtraction                             |            |
| 6     | `<<`, `>>`                                                       | Bitwise Shifts                                    |            |
| 7     | `&`                                                              | Bitwise AND                                       |            |
| 8     | `^`                                                              | Bitwise XOR                                       |            |
| 9     | `                                                                | `                                                 | Bitwise OR |
| 10    | `==`, `!=`, `>`, `>=`, `<`, `<=`, `is`, `is not`, `in`, `not in` | Comparisons, Identity, Membership                 |            |
| 11    | `not`                                                            | Logical NOT                                       |            |
| 12    | `and`                                                            | Logical AND                                       |            |
| 13    | `or`                                                             | Logical OR                                        |            |

---

## ❓ Interview Preparation (Operators & Logic)

1. **Q: What is the main difference between `==` and `is`?**
   - *A: `==` compares the **values** of the objects (equality), while `is` compares the **memory addresses** (identity). In DevOps scripts, always use `==` for strings and numbers, and reserve `is` for checking against singleton objects like `None`, `True`, or `False`.*

2. **Q: Explain "Short-circuit evaluation" in logical operators.**
   - *A: It’s an optimization where Python stops evaluating a logical expressionas soon as the result is certain. For `and`, if the first part is `False`, the whole thing must be `False`, so it stops. For `or`, if the first part is `True`, the whole thing must be `True`, so it stops. This prevents errors when the second part of a condition might fail if the first isn't met (like checking if an object exists before accessing its keys).*

3. **Q: How does `//` differ from `/`?**
   - *A: `/` performs "True Division" and always returns a **float** (e.g., `5 / 2 = 2.5`). `//` performs "Floor Division" and returns an **integer** representing the largest whole number (e.g., `5 // 2 = 2`). Use `//` when calculating things that cannot be fractional, like the number of containers to deploy.*

4. **Q: What happens if you use `+` with two lists?**
   - *A: In Python, `+` is an overloaded operator. When used with two lists, it performs **concatenation**, creating a new list containing all elements from both. (e.g., `[1, 2] + [3, 4] = [1, 2, 3, 4]`).*

5. **Q: Why is Bitwise logic important for SREs/DevOps?**
   - *A: While rare in standard automation, bitwise operators are used for low-level systems work, such as CIDR mask calculations in networking or managing Linux file permission bits (Read/Write/Execute) where each bit represents a specific capability.*
