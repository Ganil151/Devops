# 🔍 Regular Expressions: The Precision Scalpel

> **"If you have a problem and you decide to use regex, now you have two problems. But if you're a DevOps engineer with 10 gigabytes of unstructured log files, regex is the ONLY solution."**

![Regex matching visualization](../../../03-go-basics/part-02-go-architecture/07-regular-expressions/go-regex-hero.png)

---

## 🧠 The Mental Model: The Data Extractor

**The Junior Struggle**: "I'll just split the string by spaces and hope the columns align."

**The Engineer Solution**: Text is messy. Logs drift. Regex is a **Pattern Language** that describes the structure of data, allowing you to extract exactly what you need regardless of surrounding noise.

### 🏗️ The Infrastructure Analogy

Think of Regex like a **DNA Probe**:

| Concept | DNA Probe Analogy | Regex Equivalent |
|:--------|:------------------|:-----------------|
| **Pattern** | Sequence to find | `r"\d{3}-\d{2}-\d{4}"` |
| **Search** | Scanning the sample | `re.search(pattern, text)` |
| **Capture Group** | Isolating a specific gene | `(?P<ssn>...)` |
| **Substitution** | Gene Editing (CRISPR) | `re.sub(pattern, replacement)` |
| **Flags** | Test Conditions | `re.IGNORECASE | re.MULTILINE` |

**The Key Insight**: You don't tell Python *how* to find it (iterate by char). You tell Python *what* it looks like.

---

**The Difference**: You can turn 10GB of messy logs into a structured CSV, JSON, or metrics dashboard.

---

## 🆚 Junior Way vs. Engineer Way

| Feature | The Junior Way (Problematic) | The Engineer Way (Production-ready) |
|:---|:---|:---|
| **Parsing Strategy** | `.split()` and index guessing | Compiled Regular Expressions |
| **Readability** | `match.group(1)` (Magic numbers) | `match.group("user_id")` (Named) |
| **Logic** | Multiple nested `if "substring" in line` | Single refined pattern |
| **Performance** | Repeated search in a loop | `re.compile()` outside the loop |
| **Flexibility** | Breaks if extra spaces appear | `\s+` robustly handles whitespace |

---

### 🎨 Visual: The Capture Group Concept

```mermaid
graph LR
    A[Raw Log String] --> B{Regex Matcher}
    B --> C[Group 0: Total Match]
    B --> D[Group 1: 'timestamp']
    B --> E[Group 2: 'level']
    B --> F[Group 3: 'message']
    
    style C fill:#f9f,stroke:#333
    style D fill:#bbf,stroke:#333
    style E fill:#bfb,stroke:#333
    style F fill:#fbb,stroke:#333
```

**The Power of Isolation**: Without regex, you have a string of text. With regex, you have a **structured record** with individual fields you can sort, filter, and analyze.

---

---

## 🎯 Learning Objectives

By the end of this module, you will:

- ✅ **Master Regex Syntax**: Anchors, Quantifiers, Classes
- ✅ **Use Named Groups**: `(?P<name>...)` for self-documenting code
- ✅ **Compile Patterns**: Optimize for high-performance loops
- ✅ **Sanitize Data**: Mask passwords using `re.sub`
- ✅ **Avoid Pitfalls**: Greedy vs Non-Greedy matching
- ✅ **Debug Patterns**: Use raw strings `r"..."`

---

## 🏗️ Part 1: The Building Blocks

### 🧠 The Mental Model: The Lego Kit

**The Concept**: Regex creates complex logic from simple symbols.

| Symbol | Name | Meaning | DevOps Example |
|:-------|:-----|:--------|:---------------|
| `.`    | Dot | Any character (except newline) | `Log.*` matches "Log" then anything |
| `\d`   | Digit | Any number [0-9] | `\d{3}` matches "404" or "500" |
| `\w`   | Word | Alphanumeric [a-zA-Z0-9_] | `\w+` matches "user_id_1" |
| `\s`   | Space | Whitespace (tab, space) | `\s+` matches variable spacing |
| `^`    | Caret | Start of line | `^ERROR` matches line starting with ERROR |
| `$`    | Dollar | End of line | `.json$` matches files ending in .json |

### 🔧 Basic Matching

```python
import re

log_line = "Error: Connection timed out after 300ms from 10.0.0.5"

# 1. Search (Find anywhere)
if re.search(r"timed out", log_line):
    print("Found timeout!")

# 2. Match (Start only - usually avoid this, use search with ^)
if re.match(r"Error", log_line):
    print("Line starts with Error")

# 3. Find All (List of strings)
ips = re.findall(r"\d+\.\d+\.\d+\.\d+", log_line)
print(ips) # ['10.0.0.5']
```

---

## 📸 Part 2: Named Capture Groups (The Pro Standard)

### 🧠 The Mental Model: The Labeled Bucket

**The Junior Way**: Access groups by number `match.group(1)`. This breaks if you change the regex.

**The Pro Way**: Name your groups `(?P<name>...)`.

### 🔧 Implementation

```python
import re

log = "2026-02-01 12:00:00 [ERROR] User 'admin' failed login from 192.168.1.5"

# ❌ Fragile (Numeric Groups)
# pattern = r"(\d+-\d+-\d+) \d+:\d+:\d+ \[(\w+)\] User '(\w+)'"
# match.group(1) # What was group 1 again? Date?

# ✅ Robust (Named Groups)
# Syntax: (?P<name>pattern)
pattern = re.compile(
    r"(?P<date>\d{4}-\d{2}-\d{2}).*?"  # Date
    r"\[(?P<level>\w+)\].*?"           # Level
    r"User '(?P<user>\w+)'.*?"         # User
    r"from (?P<ip>[\d\.]+)"            # IP
)

match = pattern.search(log)

if match:
    data = match.groupdict()
    print(data)
    # {
    #   'date': '2026-02-01', 
    #   'level': 'ERROR', 
    #   'user': 'admin', 
    #   'ip': '192.168.1.5'
    # }
    
    # Access individual fields
    print(f"Alert: {data['user']} caused {data['level']}")
```

**Why it matters**: You can now export `match.groupdict()` directly to JSON logging systems!

---

## ⚡ Part 3: Compiling for Speed

### 🧠 The Mental Model: Pre-Heating the Oven

**The Concept**: Parsing a regex string takes CPU time. If you use the same regex 1,000,000 times in a loop, you waste massive resources.

**The Solution**: Compile it once, use it many times.

### 🔧 Pre-Compilation

```python
import re

# ❌ Slow (Re-compiles every iteration)
for line in infinite_logs:
    re.search(r"ERROR", line)

# ✅ Fast (Compiles once)
# "Bytecode" for the regex engine
error_pattern = re.compile(r"ERROR")

for line in infinite_logs:
    error_pattern.search(line)
```

**Note**: Python does cache the last few regexes automatically, but explicit compilation is best practice for clarity and performance in tight loops.

---

## 🧼 Part 4: Sanitization (Substitution)

### 🧠 The Mental Model: The Redaction Pen

**The Concept**: You cannot log passwords or API keys. You must scrub them *before* writing to disk.

### 🔧 `re.sub` Pattern

```python
import re

log_entry = "API Request: endpoint=/login params={user='alice', password='SuperSecretPassword123'}"

# Security Rule: Redact anything after password= until the next quote
# Pattern explanation:
# password=  : Literal match
# ['\"]      : Match either single or double quote
# (README.md)      : Match anything (Group 1) - Non-greedy!
# ['\"]      : Match closing quote
clean_log = re.sub(
    r"password=['\"](readme.md)['\"]", 
    "password='***REDACTED***'", 
    log_entry
)

print(clean_log)
# Output: API Request: ... password='***REDACTED***' ...
```

---

## 🧲 Part 5: Greedy vs Non-Greedy

### 🧠 The Mental Model: The Hungry Hippo

**The Concept**: Regex is **Greedy** by default. It eats as much as it can.

`<div>Hello</div><div>World</div>`

- **Greedy** `<div>.*</div>`: Matches `<div>Hello</div><div>World</div>` (From first to last).
- **Non-Greedy** `<div>.*?</div>`: Matches `<div>Hello</div>` (Stops at first match).

**The Syntax**: Add `?` after a quantifier (`*`, `+`) to make it non-greedy (lazy).

---

## 🏆 Real-World DevOps Story: The 10GB Log Audit

**The Scenario**: A security audit required a list of every user who logged into the jumpbox in the last 30 days. The only record was a 10TB pile of compressed logs.

**The Attempt**: `grep` was too slow because the logic was complex ("Find lines where User matches X OR Y but NOT Z").

**The Solution**: The engineer wrote a Python script with **Compiled Regex**.
```python
pattern = re.compile(r"Accepted publickey for (?P<user>\w+) from (?P<ip>[\d\.]+)")
unique_users = set()

for line in file_stream:
    if m := pattern.search(line):
        unique_users.add(m.group("user"))
```

**The Outcome**: The script processed 10GB in 3 minutes. The audit was passed, and the script became part of the daily SRE dashboard.

---

## ❓ Interview Preparation (Regex)

### 🎯 Core Concepts

1. **Q: What is a Raw String (`r"..."`) in Python?**
   - *A: It tells Python to treat backslashes as literal characters, not escape sequences. Essential for regex where `\b`, `\d`, etc. are common.*

2. **Q: `re.match` vs `re.search`?**
   - *A: `match` checks ONLY the start of the string. `search` checks ANYWHERE in the string. In parsing, `search` is safer.*

3. **Q: How do you handle case-insensitivity?**
   - *A: Compile with the flag: `re.compile(r"pattern", re.IGNORECASE)`.*

4. **Q: What is a Capture Group?**
   - *A: Parentheses `(...)` that isolate part of the match for extraction. Named groups `(?P<name>...)` are preferred.*

5. **Q: What does `.` match?**
   - *A: Any character *except* a newline.*

### 🚀 Advanced Questions

6. **Q: How do you match a literal `.`?**
   - *A: Escape it: `\.`.*

7. **Q: What is "Catastrophic Backtracking" (ReDoS)?**
   - *A: A poorly written regex (e.g., `(a+)+`) that takes exponential time to match certain inputs, potentially freezing the CPU and causing a Denial of Service.*

8. **Q: Explain `\b` (Word Boundary).**
   - *A: It matches the position between a word character (`\w`) and a non-word character. Useful for matching "cat" but not "catalog".*

9. **Q: How do you match a multiline block?**
   - *A: Use `re.DOTALL` flag (makes `.` match newlines too).*

10. **Q: Can you perform a replacement with logic?**
    - *A: Yes, `re.sub` accepts a function as the replacement argument. `re.sub(pattern, my_func, text)`.*

---

## 📝 Knowledge Check

### 🧠 Beginner Level

1. **Which character matches ANY digit?**
   - [ ] a) `\w`
   - [x] b) `\d`
   - [ ] c) `\s`

2. **What does `*` mean?**
   - [ ] a) 1 or more
   - [x] b) 0 or more
   - [ ] c) 0 or 1

3. **How do you denote a named group "id"?**
   - [x] a) `(?P<id>...)`
   - [ ] b) `(name=id...)`
   - [ ] c) `<id>...`

### 🚀 Intermediate Level

4. **Why use `re.compile()`?**
   - [x] a) Performance optimization for repeated use
   - [ ] b) It is required for named groups
   - [ ] c) It makes the pattern case-insensitive

5. **Where does `^` anchor the match?**
   - [ ] a) End of line
   - [x] b) Start of line
   - [ ] c) Start of word

6. **Which flag makes `.` match newlines?**
   - [ ] a) `re.MULTILINE`
   - [x] b) `re.DOTALL`
   - [ ] c) `re.GLOBAL`

### 🏆 Advanced Level

7. **The pattern `<div>.*</div>` is...**
   - [x] a) Greedy
   - [ ] b) Non-Greedy (Lazy)
   - [ ] c) Recursive

8. **Regex `\d{3}` matches...**
   - [ ] a) 3 or more digits
   - [x] b) Exactly 3 digits
   - [ ] c) Up to 3 digits

---

## 🎯 Key Takeaways for Juniors

### 🧠 Mental Models Over Syntax

1. **Regex = DNA Probe**: Describe the shape, catch the data.
2. **Compile = Preheat**: Do it once, use it loop.
3. **Named Groups = Labeling**: Don't use magic numbers.

### 🛡️ Safety Patterns

1. **Use Raw Strings** (`r"..."`).
2. **Make it Lazy** (`.*?`), not Greedy, unless necessary.
3. **Anchor it** (`^...$`) to avoid partial matches.

### 🚀 Production Rules

1. **Sanitize Data** before logging.
2. **Test Patterns** (tools like regex101.com are vital).
3. **Comment Complex Regex** (Use `re.VERBOSE` flag for multi-line commented regex).

---

## 🔗 Next Steps

You can now parse unstructured text. But what if you need to fetch that text from the web?

**Proceed to**: [Working with the Web →](../../part-03-python-systems-drafting/05-working-with-the-web/readme.md)

---

## 📚 Additional Resources

- [Regex101 (The Best Tool)](https://regex101.com/r/cO8lqs/4)
- [Python Regex Docs](https://docs.python.org/3/library/re.html)
- [Mastering Regex (O'Reilly Book)](http://shop.oreilly.com/product/9780596528126.do)

---

**🎓 Remember**: A newbie splits strings. An engineer writes regex. A senior engineer writes **readable, named, compiled** regex.
