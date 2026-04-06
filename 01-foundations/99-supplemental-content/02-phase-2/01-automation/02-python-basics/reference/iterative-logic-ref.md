# Python Iterative Logic & Loops: The DevOps Reference

> **Navigation**: [DevOps Home](../readme.md) → [Automation](../readme.md) → [Python Basics](../../readme.md) → Iterative Logic Ref
>
> **Purpose**: A technical dictionary and high-performance reference for loop structures, control flow keywords, and iteration handling in Python.

---

## 01 - Core Loop Structures

### The `for` Loop (Finite Iteration)
**Definition**: A control flow statement for specifying iteration, which allows code to be executed repeatedly for each item in a sequence (List, Tuple, String, Range).
**DevOps Context**: Used for processing **fixed inventories** (e.g., list of servers, lines in a file). Safe from infinite loops.

```python
# Syntax
for item in iterable:
    process(item)
```

| Component | Definition |
| :--- | :--- |
| **Iterable** | Any object capable of returning its members one at a time (list, str, tuple). |
| **Iterator** | The object representing the stream of data. |

### The `while` Loop (Indefinite Iteration)
**Definition**: A control flow statement that allows code to be executed repeatedly based on a given boolean condition.
**DevOps Context**: Used for **Polling** and **Wait Patterns** (e.g., waiting for an API status to change).
**⚠️ Risk**: Can create "Infinite Loops" if the condition never becomes `False`. Always implement a timeout.

```python
# Syntax
while condition_is_true:
    poll_status()
```

---

## 02 - Loop Control Keywords

These keywords alter the natural flow of a loop.

| Keyword | Definition | Action | DevOps Example |
| :--- | :--- | :--- | :--- |
| **`break`** | Terminate Loop | Exits the loop immediately. Skips `else` block. | Stop a deployment if a critical error occurs on the first server. |
| **`continue`**| Skip Iteration | Jumps immediately to the next item in the loop. | parsing logs: ignore "INFO" lines but process "ERROR" lines. |
| **`else`** | Completion Handler | Runs **only** if the loop exhausts all items (didn't hit `break`). | Checking if *any* server failed. If loop finishes without finding a failure, run `else` to mark "All Good". |
| **`pass`** | Null Operation | Does nothing. Placeholder for syntactically required code. | Creating a stub function `def todo(): pass` to be filled later. |

### 🔍 Visual Logic: For-Else Pattern
```python
for server in fleet:
    if server.is_down():
        alert()
        break # Skips the 'else' block
else:
    print("All servers checked. System Healthy.") # Runs if no break occurred
```

---

## 03 - Iteration Helpers (Built-ins)

DevOps automation rarely involves simple counting. These functions add context and capability to loops.

### `enumerate(iterable, start=0)`
**Definition**: Adds a counter to an iterable and returns it as an enumerate object (pairs of index, value).
**Return Type**: Iterator yielding `(int, value)`.
**DevOps Use**: Tracking line numbers in log files or row numbers in CSV imports.

```python
# Instead of: i = 0; for x in list: ... i += 1
for index, server in enumerate(servers, start=1):
    print(f"Server #{index}: {server}")
```

### `zip(*iterables)`
**Definition**: Aggregates elements from each of the iterables. Returns an iterator of tuples, where the i-th tuple contains the i-th element from each of the argument sequences.
**Return Type**: Iterator yielding `(val1, val2, ...)`.
**Stops At**: The length of the **shortest** input iterable.
**DevOps Use**: Pairing Hostnames with IP Addresses for a unified inventory dict.

```python
names = ["web", "db"]
ips = ["10.0.0.1", "10.0.1.1"]
mapping = dict(zip(names, ips)) # {'web': '10.0.0.1', ...}
```

### `range(start, stop, step)`
**Definition**: Generates an immutable sequence of numbers.
**Performance**: Lazy evaluation (O(1) memory). It does not generate the numbers until iterated.
**DevOps Use**: Retrying an operation `N` times.

```python
for attempt in range(1, 4): # Generates 1, 2, 3
    print(f"Retry attempt {attempt}...")
```

---

## 04 - Comprehensions (High-Performance Iteration)

Comprehensions provide a concise way to create lists, dicts, and sets. They are generally faster than standard for-loops efficiently implemented in C.

### List Comprehension
**Syntax**: `[expression for item in iterable if condition]`
**DevOps Use**: Filtering inventory lists.

```python
# Get all 'prod' servers
prod_servers = [s for s in inventory if "prod" in s]
```

### Dict Comprehension
**Syntax**: `{key_expr: val_expr for item in iterable}`
**DevOps Use**: Reformatting API responses.

```python
# Convert list of tuples to dict
tags = [("Env", "Prod"), ("Role", "Web")]
tag_dict = {key: val for key, val in tags}
```

---

## 05 - Complexity & Performance Reference

| Operation | Complexity | Note |
| :--- | :--- | :--- |
| **Standard For Loop** | **O(n)** | Linear time. |
| **Limitless While Loop** | **O(∞)** | Infinite if unchecked. |
| **`len(range(n))`** | **O(1)** | Math calculation, not iteration. |
| **`x in range(n)`** | **O(1)** | Math check (Python 3 optimization). |
| **List Comprehension** | **O(n)** | Slightly faster overhead than raw Python loop. |
| **`zip()` / `enumerate()`** | **O(1)** | Creation is instant (Lazy); Iteration is O(n). |

---

## 🔍 The Interviewer's Trap: Iteration Risks

### 1. Modifying List While Iterating
**Trap**: Deleting items from a list you are currently looping over.
**Result**: Skips items or raises `IndexError`.
**Fix**: Iterate over a copy or use comprehension.

```python
# ❌ BAD
for user in users:
    if user.inactive:
        users.remove(user) # Breaks the internal iterator index!

# ✅ GOOD
active_users = [u for u in users if not u.inactive]
```

### 2. Late Binding in Closures
**Trap**: Using a loop variable inside a lambda/function defined in the loop.
**Result**: All functions use the *last* value of the loop variable.

```python
# ❌ TRAP: All print 9
funcs = [lambda: print(i) for i in range(10)] 

# ✅ FIX: Default argument binds value immediately
funcs = [lambda x=i: print(x) for i in range(10)]
```
