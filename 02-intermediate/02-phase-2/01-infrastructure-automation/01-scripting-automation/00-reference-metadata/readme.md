# 📚 Advanced Bash Reference: Keyword Encyclopedia

This reference hub provides a deep-dive into the technical keywords, configurations, and syntax used in production-grade automation. Use these guides to master the "Why" behind the "How."

---

## 🏗️ Reference Manuals

Choose a topic to explore its core architectural keywords:

### 1. [🛡️ Robust Execution](./robust-execution-keywords.md)
Fail-fast protocols (`set -e`), Signal management (`trap`), and Mutex locking (`flock`).

### 2. [📟 Argument Parsing](./argument-parsing-keywords.md)
Building CLI interfaces with `getopts`, handling `$OPTARG`, and standardizing `usage()` menus.

### 3. [🔍 JQ Processing](./jq-processing-keywords.md)
Transforming API data with iteration (`[]`), filtering (`select`), and raw transformation (`-r`).

### 4. [🧶 Sed & Awk](./sed-awk-keywords.md)
Mastering stream editing and columnar data reporting using the "Grandfather" tools of Unix.

### 5. [⚡ Parallelism](./parallelism-keywords.md)
Scaling execution with `xargs -P`, backgrounding tasks, and coordinating with `wait`.

---

## 🛠️ The "Staff Level" Benchmark

In Advanced Bash, your code is no longer judged by "Does it work?", but by "How does it handle the edge cases?".

| Junior Engineer | Staff Automation Engineer |
| :--- | :--- |
| Uses `$1`, `$2` | Uses `getopts` for named flags. |
| Ignores API failures | Uses `set -o pipefail` to catch silent pipeline errors. |
| Runs tasks sequentially | Uses `xargs -P` for concurrent processing. |
| Leaves messy temp files | Uses `trap ... EXIT` to guarantee system cleanliness. |
| Manually checks state | Uses `flock` and atomic `mv` to manage state changes safely. |

---

[⬅️ Back to Advanced Bash](../readme.md)
