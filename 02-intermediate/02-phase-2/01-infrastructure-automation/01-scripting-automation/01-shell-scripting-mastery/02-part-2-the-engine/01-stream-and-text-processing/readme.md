# 📜 Data Processing: The Power of Streams (Sed, Awk, Jq)

> **"In the Unix philosophy, text is the universal interface. If you can manipulate text streams, you can manipulate the world."**

Welcome to the **Data Processing** module. DevOps is ultimately about moving data from one place to another: Logs to Dashboards, Configs to Servers, API Responses to Reports. This module gives you the "Superpowers" to transform this data in-flight without needing to write full Python scripts.

**Why This Matters for Junior DevOps Engineers:**
- ⚡ **Speed**: Parsing a 1GB log file with `awk` takes seconds. Python might take minutes and eat RAM.
- 🔧 **Ad-Hoc Queries**: "How many 500 errors happened in the last hour?" is a one-line `awk` command.
- 🎯 **Interview**: "Extract the IP address from this string" is a guaranteed whiteboard question.
- ☁️ **Cloud Glue**: `curl` + `jq` is the standard way to debug Kubernetes and AWS APIs.

---

## 📚 Table of Contents

1. [The Stream Philosophy](#-the-stream-philosophy)
2. [The Trinity: Sed, Awk, Jq](#-the-trinity-sed-awk-jq)
3. [When to Use What?](#-when-to-use-what)
4. [Real-World DevOps Scenarios](#-real-world-devops-scenarios)
5. [Performance & Safety](#-performance--safety)
6. [Common Pitfalls & Solutions](#-common-pitfalls--solutions)
7. [Hands-On Exercises](#-hands-on-exercises)
8. [Next Steps](#-next-steps)

---

## 🌊 The Stream Philosophy

In Linux, we process data as a **Stream** (STDIN -> STDOUT). We don't load the whole file into RAM (like Notepad would). We process it line-by-line.

```mermaid
graph LR
    Input[Data Source: Logs/API] -->|Pipe | Filter[Grep: Filter Rows]
    Filter -->|Pipe | Transform[Sed/Awk: Change Columns]
    Transform -->|Pipe | Format[Jq: Structure JSON]
    Format --> Output[Final Report]
    
    style Input fill:#fef3c7,stroke:#d97706
    style Transform fill:#e0f2fe,stroke:#0369a1
    style Output fill:#f0fdf4,stroke:#15803d
```

### 🔍 Concept Breakdown

**1. The Pipe (`|`)**
- Connects the Output of Command A to the Input of Command B.
- **Buffers**: Data flows in chunks (4KB - 64KB).

**2. The Filter (`grep`)**
- Removes noise. "I only want lines with 'ERROR'".

**3. The Transformer (`sed`/`awk`)**
- Modifies data. "Replace 'User' with 'ID'" or "Sum column 3".

---

## 🛠️ The Trinity: Sed, Awk, Jq

### 1. Sed (Stream Editor)
**The Surgeon.**
Use it for **Regex Substitution**.
- "Find X and replace it with Y".
- "Delete lines 1-10".

### 2. Awk (Aho, Weinberger, and Kernighan)
**The Accountant.**
Use it for **Columnar Data** operations.
- "Print the 3rd word of every line".
- "Sum the values in column 5".
- "If column 2 is 'Error', print line".

### 3. Jq (JSON Processor)
**The Architect.**
Use it for **Structured Data**.
- "Get the value of key 'id'".
- "Filter list where 'status' is 'active'".

---

## ⚖️ When to Use What?

| Task | Tool | Example |
|:---|:---|:---|
| Find simple text | `grep` | `grep "Error" file.log` |
| Replace Text | `sed` | `sed 's/foo/bar/g' file.txt` |
| Extract Columns (CSV/Logs) | `awk` | `awk '{print $1}' access.log` |
| Math (Sum/Average) | `awk` | `awk '{sum+=$1} END {print sum}'` |
| Parse JSON API | `jq` | `curl ... \| jq '.items[0].id'` |
| Complex Logic | **Python** | If script > 50 lines |

---

## 🎭 Real-World DevOps Scenarios

### 🛡️ Scenario 1: The "Secret Sanitizer" (Sed)
**Task**: Remove API keys from a config file before committing to Git.
**Solution**:
```bash
sed -i 's/api_key=.*/api_key=REDACTED/' config.ini
```

### 🔥 Scenario 2: The "Log Summarizer" (Awk)
**Task**: Count the number of requests per IP address from an Nginx log.
**Solution**:
```bash
# $1 is the IP address in standard Nginx logs
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head
```

### ☁️ Scenario 3: The "Pod Doctor" (Jq)
**Task**: Find all Kubernetes Pods that are not "Running".
**Solution**:
```bash
kubectl get pods -o json | jq '.items[] | select(.status.phase != "Running") | .metadata.name'
```

---

## ⏱️ Performance & Safety

### 1. In-Place Editing (`sed -i`)
**Danger**: It overwrites the file.
**Best Practice**: Always backup first.
```bash
sed -i.bak 's/foo/bar/' file.txt
# Creates file.txt and file.txt.bak
```

### 2. Awk Memory Usage
**Efficiency**: Awk processes line-by-line, so it uses constant RAM unless you store huge arrays.
**Tip**: It's faster than Python for simple CSV processing.

---

## ⚠️ Common Pitfalls

### Pitfall 1: Parsing JSON with Grep/Sed
**Bad**: `grep "id" file.json`
**Why**: JSON structure varies (indentation, line breaks). Grep is line-based.
**Fix**: ALWAYS use `jq`.

### Pitfall 2: Too Many Pipes
**Bad**: `cat file.txt | grep "foo" | awk ...`
**Why**: Useless use of `cat`.
**Fix**: `grep "foo" file.txt | awk ...` or `awk '/foo/ ...' file.txt`.

---

## 🎯 Hands-On Exercises

### Exercise 1: The Log Cleaner
**Objective**: Create a pipeline to clean a messy log file.
1. Remove lines starting with `#`.
2. Extract the 3rd column (User ID).
3. Save to `users.txt`.

### Exercise 2: The API Filter
**Objective**: Use `jq` to filter users.
1. Curl `https://jsonplaceholder.typicode.com/users`.
2. Select users where `address.city` starts with "S".
3. Print their `email`.

---

## 🔗 Sub-Modules

Dive deep into each tool:

- **[03-JSON-Processing-with-JQ](./03-json-processing-with-jq/readme.md)**: Mastering JSON APIs.
- **[04-Data-Wrangling-with-Sed-and-Awk](./04-data-wrangling-with-sed-and-awk/readme.md)**: Advanced Stream Editing.
- **[06-Regex-and-Data-Parsing](./06-regex-and-data-parsing/readme.md)**: The art of matching text.

---

*Verified by DevOps Team for Phase 2 Automation.*
