# Regular Expressions
*Pattern Matching for Log Parsing and Data Extraction*

Regular expressions (regex) are essential for parsing logs, validating input, and extracting data from text—core tasks in DevOps automation. Mastering regex transforms unstructured text into actionable data.

---

## 🎯 Learning Objectives

- Understand regex syntax and pattern construction
- Write regex patterns for common DevOps tasks
- Extract data from logs, configs, and command output
- Validate inputs like IP addresses, hostnames, and URLs
- Compile patterns for performance in production

---

## 📊 Regex Workflow

```mermaid
flowchart TD
    A[Input Text] --> B[Compile Pattern]
    B --> C[Apply to Text]
    C --> D{Match Found?}
    D -->|Yes| E[Extract Groups]
    D -->|No| F[No Match - Handle]
    E --> G[Process Data]
    G --> H[Output/Action]
    
    style B fill:#306998,stroke:#ffe873,color:#fff
    style E fill:#4b8bbe,stroke:#306998,color:#fff
```

---

## 📊 Regex Components

```mermaid
flowchart LR
    subgraph "Regex Pattern Components"
        A[Literal Characters<br>abc, 123] --> B[Metacharacters<br>. * + ? ^  $]
        B --> C[Character Classes<br>\d \w \s]
        C --> D[Quantifiers<br>{n} {n,m} + *]
        D --> E[Groups<br>() (?:) (?P<name>)]
        E --> F[Anchors<br>^ $ \b]
    end
    
    style A fill:#306998,stroke:#ffe873,color:#fff
```

---

## 📚 Core Concepts

### 1. Basic Pattern Matching

```python
import re

log_line = "2026-01-11 10:30:45 ERROR Server connection failed"

# search() - Find pattern anywhere in string
if re.search(r"ERROR", log_line):
    print("Found error!")

# match() - Match at beginning of string
if re.match(r"\d{4}-\d{2}-\d{2}", log_line):
    print("Starts with date")

# fullmatch() - Match entire string (Python 3.4+)
if re.fullmatch(r"\d{4}-\d{2}-\d{2}", "2026-01-11"):
    print("Is a valid date format")

# findall() - Find all occurrences
text = "Connect from 10.0.0.1 and 192.168.1.100"
ips = re.findall(r"\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}", text)
print(ips)  # ['10.0.0.1', '192.168.1.100']

# finditer() - Returns iterator of match objects
for match in re.finditer(r"\d+", "Server 1, Server 2, Server 3"):
    print(f"Found number: {match.group()} at position {match.start()}")
```

### 2. Pattern Syntax Reference

| Pattern | Meaning | Example |
|---------|---------|---------|
| `.` | Any character (except newline) | `a.c` → "abc", "a1c" |
| `*` | Zero or more | `lo*g` → "lg", "log", "looog" |
| `+` | One or more | `lo+g` → "log", "looog" |
| `?` | Zero or one | `colou?r` → "color", "colour" |
| `{n}` | Exactly n | `\d{4}` → "2026" |
| `{n,m}` | Between n and m | `\d{1,3}` → "1", "12", "123" |
| `^` | Start of string | `^Error` |
| `$` | End of string | `failed$` |
| `\b` | Word boundary | `\bweb\b` → "web" not "website" |
| `\d` | Digit [0-9] | `\d+` → "123" |
| `\w` | Word char [a-zA-Z0-9_] | `\w+` → "server_01" |
| `\s` | Whitespace | `\s+` → " ", "\t\n" |
| `\D`, `\W`, `\S` | Negations | `\D+` → non-digits |
| `[abc]` | Character set | `[aeiou]` → vowels |
| `[^abc]` | Negated set | `[^0-9]` → non-digits |
| `[a-z]` | Range | `[a-zA-Z]` → letters |
| `|` | Alternation (OR) | `ERROR|WARN` |

### 3. Capture Groups

```python
import re

log_line = "2026-01-11 10:30:45 ERROR [web-01] Connection timeout"

# Basic groups with ()
pattern = r"(\d{4}-\d{2}-\d{2}) (\d{2}:\d{2}:\d{2}) (\w+) \[(\w+-\d+)\] (.+)"
match = re.match(pattern, log_line)

if match:
    # Access by index
    date = match.group(1)      # "2026-01-11"
    time = match.group(2)      # "10:30:45"
    level = match.group(3)     # "ERROR"
    server = match.group(4)    # "web-01"
    message = match.group(5)   # "Connection timeout"
    
    # Unpack all groups
    date, time, level, server, message = match.groups()
    
    print(f"Server {server}: {level} - {message}")
```

### 4. Named Groups

```python
import re

log_line = "2026-01-11 10:30:45 ERROR [web-01] Connection timeout"

# Named groups with (?P<name>...)
pattern = r"(?P<date>\d{4}-\d{2}-\d{2}) (?P<time>\d{2}:\d{2}:\d{2}) (?P<level>\w+) \[(?P<server>\w+-\d+)\] (?P<message>.+)"

match = re.match(pattern, log_line)

if match:
    # Access by name (much clearer!)
    print(f"Date: {match.group('date')}")
    print(f"Server: {match.group('server')}")
    print(f"Level: {match.group('level')}")
    
    # Get as dictionary
    data = match.groupdict()
    print(data)
    # {'date': '2026-01-11', 'time': '10:30:45', 'level': 'ERROR', 
    #  'server': 'web-01', 'message': 'Connection timeout'}
```

### 5. Common DevOps Patterns

```python
import re

# ========== IP Address ==========
IP_PATTERN = r"\b(\d{1,3}\.){3}\d{1,3}\b"
# Better (validates octets 0-255):
IP_STRICT = r"\b(?:(?:25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)\b"

# ========== Hostname ==========
HOSTNAME_PATTERN = r"\b[a-zA-Z0-9](?:[a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z]{2,})+\b"

# ========== Email ==========
EMAIL_PATTERN = r"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b"

# ========== URL ==========
URL_PATTERN = r"https?://[^\s]+"

# ========== Log Timestamp Formats ==========
ISO_TIMESTAMP = r"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:?\d{2})?"
SYSLOG_TIMESTAMP = r"\w{3}\s+\d{1,2}\s+\d{2}:\d{2}:\d{2}"
APACHE_TIMESTAMP = r"\d{2}/\w{3}/\d{4}:\d{2}:\d{2}:\d{2}\s+[+-]\d{4}"

# ========== Docker/Container ==========
CONTAINER_ID = r"\b[a-f0-9]{12,64}\b"
IMAGE_TAG = r"[\w\-./]+:[\w\-.]+"

# ========== Kubernetes ==========
K8S_POD_NAME = r"[a-z0-9]+(?:-[a-z0-9]+)*-[a-z0-9]{5,10}"
K8S_NAMESPACE = r"[a-z0-9]+(?:-[a-z0-9]+)*"

# ========== AWS ==========
ARN_PATTERN = r"arn:aws:[a-z0-9-]+:[a-z0-9-]*:\d*:[\w\-\/]+"
INSTANCE_ID = r"i-[a-f0-9]{8,17}"
```

### 6. Substitution with re.sub()

```python
import re

# Simple replacement
text = "Contact admin@old-domain.com for support"
new_text = re.sub(r"old-domain\.com", "new-domain.com", text)

# Remove sensitive data
log = "User password=secret123 logged in"
sanitized = re.sub(r"password=\S+", "password=***", log)
print(sanitized)  # "User password=*** logged in"

# Use capture groups in replacement
hosts = "server1.example.com, server2.example.com"
updated = re.sub(r"example\.com", "newdomain.io", hosts)

# Use function for dynamic replacement
def mask_ip(match):
    ip = match.group()
    parts = ip.split('.')
    return f"{parts[0]}.{parts[1]}.xxx.xxx"

log = "Connection from 192.168.1.100 accepted"
masked = re.sub(r"\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}", mask_ip, log)
print(masked)  # "Connection from 192.168.xxx.xxx accepted"
```

### 7. Compiling Patterns for Performance

```python
import re

# Compile for repeated use (more efficient)
log_pattern = re.compile(
    r"(?P<timestamp>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}) "
    r"(?P<level>\w+) "
    r"\[(?P<source>\w+)\] "
    r"(?P<message>.*)",
    re.IGNORECASE
)

# Use compiled pattern
for line in log_lines:
    match = log_pattern.match(line)
    if match:
        process(match.groupdict())
```

### 8. Flags

| Flag | Meaning |
|------|---------|
| `re.IGNORECASE` or `re.I` | Case-insensitive matching |
| `re.MULTILINE` or `re.M` | ^ and $ match line boundaries |
| `re.DOTALL` or `re.S` | . matches newlines too |
| `re.VERBOSE` or `re.X` | Allow comments in pattern |

```python
import re

# Verbose pattern with comments
log_pattern = re.compile(r"""
    (?P<date>\d{4}-\d{2}-\d{2})     # Date YYYY-MM-DD
    \s+                              # Whitespace
    (?P<time>\d{2}:\d{2}:\d{2})     # Time HH:MM:SS
    \s+                              # Whitespace
    (?P<level>\w+)                   # Log level
    \s+                              # Whitespace
    (?P<message>.*)                  # Rest of message
""", re.VERBOSE)
```

---

## 🛠️ Hands-On Challenges

Master pattern matching by building these essential DevOps regex utilities.

| Challenge | Description | Starter Code | Solution |
| :--- | :--- | :--- | :--- |
| **01. NGINX Log Parser** | Extract structured data from raw NGINX access logs using named capture groups. | [Link](./challenges/challenge_01_nginx_parser.py) | [Link](./challenges/solutions/solution_01_nginx_parser.py) |
| **02. Sensitive Data Masker** | Sanitize logs by automatically masking passwords and IP addresses with regex substitution. | [Link](./challenges/challenge_02_data_masker.py) | [Link](./challenges/solutions/solution_02_data_masker.py) |
| **03. Log Error Aggregator** | Extract and count unique error messages from unstructured application logs. | [Link](./challenges/challenge_03_error_aggregator.py) | [Link](./challenges/solutions/solution_03_error_aggregator.py) |
| **04. Configuration Extractor** | Parse dynamic KEY=VALUE configuration formats while ignoring comments and whitespace. | [Link](./challenges/challenge_04_config_extractor.py) | [Link](./challenges/solutions/solution_04_config_extractor.py) |

> **Pro Tip**: Use `re.VERBOSE` when writing complex patterns—it allows you to add comments and whitespace, making your regex much easier for others (and yourself) to maintain.

---

## 📖 Real-World Story: The Log Parser

**Scenario**: A team spent hours manually searching through gigabytes of logs to find patterns during incidents.

**Problem**: No automated log analysis. Each incident meant:
- SSH into 10+ servers
- Manually grep through logs
- Copy-paste relevant entries
- Manually correlate data

**Solution**: Built a Python log analyzer with regex:

```python
import re
from collections import Counter

def analyze_incident_logs(log_file, time_window):
    """Analyze logs for incident patterns."""
    
    patterns = {
        "error": re.compile(r"(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}).*ERROR.*?(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})"),
        "timeout": re.compile(r"timeout|timed out|connection refused", re.I),
        "memory": re.compile(r"out of memory|oom|memory allocation", re.I)
    }
    
    findings = {"errors": [], "timeouts": 0, "memory_issues": 0, "ips": Counter()}
    
    with open(log_file) as f:
        for line in f:
            for name, pattern in patterns.items():
                if match := pattern.search(line):
                    # Process findings...
                    pass
    
    return findings
```

**Outcome**: Incident investigation time reduced from 2 hours to 15 minutes.

---

## ❓ Interview Questions

1. **What's the difference between `re.match()` and `re.search()`?**
   > `match()` only checks at the beginning of the string, while `search()` scans through the entire string for a match. Use `match()` for structured data like log lines, `search()` for finding patterns anywhere.

2. **How do you compile patterns for better performance?**
   > Use `pattern = re.compile(r"...")` once, then reuse with `pattern.match(text)`. Compiled patterns are cached internally by Python, but explicit compilation makes intent clear and is slightly faster for repeated use.

3. **Explain greedy vs. non-greedy quantifiers.**
   > Greedy (`*`, `+`) matches as much as possible. Non-greedy (`*?`, `+?`) matches as little as possible. Example: for `<div>text</div>`, `<.*>` matches the whole thing (greedy), while `<.*?>` matches just `<div>` (non-greedy).

4. **What are named groups and why use them?**
   > Named groups `(?P<name>...)` allow accessing matches by name instead of index. Makes code more readable and maintainable: `match.group('ip')` is clearer than `match.group(1)`.

5. **How do you handle multi-line text?**
   > Use re.MULTILINE (makes ^ and $ match line boundaries) and re.DOTALL (makes . match newlines). Example: `re.findall(r'^ERROR.*$', text, re.MULTILINE)`.

6. **What's the raw string prefix `r` for?**
   > Raw strings `r"..."` treat backslashes literally. Without it, `"\d"` is interpreted as escape sequence (invalid). `r"\d"` is the regex digit pattern. Always use raw strings for regex.

---

## 🧠 Quiz

1. What does `re.findall()` return?
   - a) First match
   - b) List of all matches ✅
   - c) Boolean
   - d) Iterator

2. What does `\d+` match?
   - a) Exactly one digit
   - b) One or more digits ✅
   - c) Optional digit
   - d) Zero or more digits

3. What does `\b` match?
   - a) Quote boundary
   - b) Word boundary ✅
   - c) Buffer boundary
   - d) Block boundary

4. How do you make a pattern case-insensitive?
   - a) `re.CASE`
   - b) `re.IGNORECASE` ✅
   - c) `re.NOCASE`
   - d) `re.LOWER`

5. What does `(?P<name>...)` create?
   - a) A comment
   - b) A non-capturing group
   - c) A named group ✅
   - d) A lookahead

6. What does `.*?` represent?
   - a) Greedy match
   - b) Non-greedy match ✅
   - c) Optional match
   - d) Invalid pattern

7. Which method returns a match object?
   - a) `re.findall()`
   - b) `re.match()` ✅
   - c) `re.split()`
   - d) `re.sub()`

8. What flag allows comments in patterns?
   - a) `re.COMMENTS`
   - b) `re.VERBOSE` ✅
   - c) `re.READABLE`
   - d) `re.DEBUG`

---

## 🔗 Related Topics

| Module | Relationship |
|--------|-------------|
| [Logging Basics](../../../../../../README.md) | Parse log formats |
| [File Operations](../../../../../../README.md) | Read/process log files |
| [Working with JSON](../06-Working-with-JSON/README.md) | Extract data from structured text |

---

**Next Step**: [Logging Basics →](../../../../../../README.md)
