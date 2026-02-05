# 📚 Intermediate Shell Reference: Script Samples

This directory contains a collection of production-grade shell script samples mapped to the core learning objectives of the **Intermediate Shell Scripting** track.

---

## 📂 Samples Index

| # | Sample Script | Topic | Key Engineering Concepts |
| :--- | :--- | :--- | :--- |
| **01** | [**logic_and_arrays.sh**](../01-Shell-Fundamentals/002-Intermediate-Logic/logic_and_arrays.sh) | Intermediate Logic | Associative Arrays, Regex Conditionals (`[[ =~ ]]`). |
| **02** | [**functions_modularity.sh**](../../03-Part-3-The-Building-Blocks/01-Production-Scripting-Patterns/003-Advanced-Functions-and-Modularity/functions_modularity.sh) | Modularity | Local variables, return codes, library-style logic. |
| **03** | [**log_and_io_plumbing.sh**](../../03-Part-3-The-Building-Blocks/01-Production-Scripting-Patterns/04-Advanced-IO-and-Logging/log_and_io_plumbing.sh) | I/O & Logging | Redirection (`&>`), File Descriptors (3-9), `tee`. |
| **04** | [**trap_and_signals.sh**](../../03-Part-3-The-Building-Blocks/01-Production-Scripting-Patterns/05-Signal-Handling-Legacy/trap_and_signals.sh) | Signal Handling | Automated cleanup via `trap`, `EXIT` vs `INT` vs `TERM`. |
| **05** | [**regex_and_parsing.sh**](../../02-Part-2-The-Engine/01-Stream-and-Text-Processing/06-Regex-and-Data-Parsing/regex_and_parsing.sh) | Data Parsing | The "Triple Threat": `grep -E`, `sed`, and `awk`. |

---

## 🛠️ How to Use These Samples

1.  **View & Analyze**: Read the comments inside each script. They follow the **Staff Engineer** standard of defensive programming.
2.  **Execute**: Run them locally to see the output:
    ```bash
    bash ./samples/logic_and_arrays.sh
    ```
3.  **Incorporate**: Use these patterns (Guard Clauses, Safe Headers, Traps) in your own automation projects.

---

## 🛡️ The "Basics" vs "Intermediate" Benchmark

| Feature | Junior Level | Intermediate (Pro) Level |
| :--- | :--- | :--- |
| **Header** | `#!/bin/bash` | `#!/usr/bin/env bash` + `set -euo pipefail` |
| **Variables** | All Global | `local` variables within functions |
| **Errors** | Ignored / Silent | Fail-Fast with descriptive logging |
| **Cleanup** | Manual deletion | Automated `trap 'cleanup' EXIT` |
| **Arguments** | Positional (`$1`, `$2`) | Named Flags with `getopts` or validation |

---

[⬅️ Back to Intermediate Shell](../README.md)
