# 🧩 Functions (The Art of Modularity)

> **"Don't Repeat Yourself (DRY). If you type the same logic twice, you've inherited a maintenance nightmare. If you make it a function, you've built a tool."**

![Modular Script Architecture](./modular_architecture.svg)

## 📚 Overview

Automation scripts often start as a simple list of commands. But as complexity grows (logging, error handling, retries), scripts become unreadable "Monoliths." **Functions** allow you to group code into named, logical units. They act like "Scripts within Scripts," allowing you to solve a problem once and reuse the solution a hundred times.

---

## 🎓 Learning Objectives

By the end of this module, you will:

- ✅ Define **Standard** vs **C-Style** function syntax.
- ✅ Protect the global state using the **`local` keyword**.
- ✅ Map **Function arguments** and understand local positional scoping.
- ✅ Capturing data using **Command Substitution** instead of return values.
- ✅ Build and source external **Function Libraries** for cross-script reuse.

---

## 🏗️ Structure & Syntax

A function is a name followed by a block of code wrapped in `{ }`.

### 1. Two Ways to Define
```bash
# Style A: Explicit (Best for readability)
function setup_server() {
    # code
}

# Style B: Classic (Standard POSIX)
setup_server() {
    # code
}
```

### 2. The Argument Trap (Isolated Scope)
**CRITICAL**: Parameters inside a function (`$1`, `$2`) refer to what was passed **to the function**, NOT what was passed to the main script.

```bash
#!/bin/bash
# Run as: ./script.sh global_val
function test_args() {
    echo "Function sees: $1" # Output: func_val
}

test_args "func_val"
echo "Main sees: $1"        # Output: global_val
```

---

## 🔐 Variable Protection: `local`

By default, every variable in Bash is **Global**. If you change a variable inside a function without `local`, you change it for the **entire script**.

```bash
# ⚠️ DANGEROUS: Global Collision
count=1
function increment() { count=2; }
increment
echo $count # Output: 2

# ✅ SAFE: Using Local
count=1
function safe_increment() { local count=2; }
safe_increment
echo $count # Output: 1
```

---

## 📤 Returning Data from Functions

Bash functions technically **cannot return text**. They only return an **Exit Status** (0-255). To get data out, we use "Capture":

```bash
# Pattern: The Echo-Capture
function get_timestamp() {
    echo "$(date +%Y-%m-%d)"
}

# Capturing the result
TODAY=$(get_timestamp)
```

**Using `return` for Logic**: Use `return 0` for success and `return 1` for failure.
```bash
function check_env() {
    [[ -z "$DB_URL" ]] && return 1
    return 0
}

check_env || die "Database URL missing!"
```

---

## 🏆 Real-World DevOps Case Study

### 🚨 **The Incident: The Variable Collision Loop**

**The Scenario**: A cleanup script iterated through 50 cloud regions. Inside each region loop, it called a function `delete_old_snapshots()`.

**The Bug**:
Both the main loop and the function used a variable named `i`.
```bash
# Main
for i in "${regions[@]}"; do
    delete_old_snapshots $i
done

function delete_old_snapshots() {
    for i in {1..5}; do # This OVERWROTE the main 'i'!
        echo "Deleting..."
    done
}
```
**Outcome**: The script processed the first region, the function finished with `i=5`, and the main loop saw `i=5`. If there wasn't a 5th region, the script simply stopped, leaving 49 regions uncleansed.

**The Fix**: Use `local i` inside any function containing a loop.

---

## 🎓 Interview Questions

#### Q1: Scope - Where is a 'local' variable accessible?
<details>
<summary>Click to reveal answer</summary>
A `local` variable is accessible within the function it is defined in **and all sub-functions called by that function**. It is NOT accessible by the parent/calling script.
</details>

#### Q2: What is the benefit of 'Sourcing' a file (`source library.sh`)?
<details>
<summary>Click to reveal answer</summary>
Sourcing runs the specified file in the **current shell environment** instead of a new process. This allows your script to "inherit" all functions and variables defined in the library file.
</details>

#### Q3: How do you pass an array to a function?
<details>
<summary>Click to reveal answer</summary>
Bash doesn't support passing arrays directly. You must pass the expanded elements `func "${array[@]}"` and rebuild it inside, or pass the array name and use indirect referencing (advanced). 
Recommended: `func "${my_array[@]}"`.
</details>

---

## 📝 Knowledge Check

1. **How do you call a function named `cleanup`?**
   - [ ] a) `call cleanup`
   - [x] b) `cleanup`
   - [ ] c) `cleanup()`
   - [ ] d) `run cleanup()`

2. **Which command returns an error status from a function?**
   - [ ] a) `exit 1` (This exits the whole script!)
   - [ ] b) `echo 1`
   - [x] c) `return 1`
   - [ ] d) `stop 1`

3. **What is the standard way to import a function library?**
   - [ ] a) `import library.sh`
   - [x] b) `source library.sh`
   - [ ] c) `./library.sh`
   - [ ] d) `bash library.sh`

4. **Variables in Bash are ________ by default.**
   - [ ] a) Local
   - [x] b) Global
   - [ ] c) Hidden
   - [ ] d) Immutable

**Answers**: 1-b, 2-c, 3-b, 4-b

## 🔗 Additional Resources
- [The Shellcheck Linter (Detects Local Variable Bugs)](https://www.shellcheck.net/)
- [Modularizing Bash Scripts](https://medium.com/@life-is-short-so-enjoy-it/modularizing-bash-scripts-f1d2b7193d2b)

---
**📌 Pro Tip**: Create a `usage()` function at the top of every script. It acts as both documentation and a safety net for users who don't know the arguments!
```bash
usage() { echo "Usage: $0 <env> <region>"; exit 1; }
[[ $# -lt 2 ]] && usage
```
