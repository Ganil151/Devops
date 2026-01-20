# Log Parsing and Regex

Logs are the source of truth, but they are messy. Regular Expressions (Regex) allow you to extract structured data from unstructured text.

## 📚 Module Structure
- **[Boilerplates](./Boilerplates/)**: `log_parser.py` (Apache Log parsing).
- **[CHALLENGES](./CHALLENGES.md)**: Log Analyzers and Error Groupers.

---

## 🔑 Key Concepts

| Concept | Description |
| :--- | :--- |
| **`re.search()`** | Finds the *first* match. |
| **`re.findall()`** | Returns a list of *all* matches. |
| **Groups `()`** | Captures specific parts of the match. |
| **`Counter`** | `collections.Counter` helps count items effortlessly. |

---

## 🏗️ Robust Parsing Patterns

### 1. Compile Once
Regex compilation is expensive. Do it globally.

```python
import re

# GOOD: Compiled once
PATTERN = re.compile(r'\d+')

def process(line):
    return PATTERN.search(line)
```

### 2. Non-Greedy Match
`.*` matches everything. `.*?` matches as little as possible.
- Text: `[ERROR] [CRITICAL]`
- `\[.*\]` matches `[ERROR] [CRITICAL]` (Greedy)
- `\[.*?\]` matches `[ERROR]` (Non-Greedy)

---

## 📖 Real-World Story: The "Incident Metric"

**Problem**: Management successfully asked "How many 500 errors happened yesterday?". Kibana was down.
**Solution**: An engineer wrote a 20-line Python script using `re` to parse the raw Nginx logs on the load balancer.
**Result**: Generated the report in 30 seconds.

---

## ❓ Interview Questions

1.  **What is the difference between `re.match` and `re.search`?**
    - *Answer*: `re.match` checks for a match only at the *beginning* of the string. `re.search` checks anywhere in the string.
2.  **How do you extract the IP address from a log line?**
    - *Answer*: Using capture groups `group(1)` on the result object.
3.  **Is Regex slow?**
    - *Answer*: It can be (Catastrophic Backtracking). For simple splits, string manipulation (`.split()`) is faster.

---

[Next: Remote Execution](../09-Remote-Execution-and-SSH/README.md)
