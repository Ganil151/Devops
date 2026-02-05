# 🧩 Functions: The Core of Modular Automation

> **"Don't Repeat Yourself (DRY). If you type the same logic twice, you've inherited a maintenance nightmare. If you make it a function, you've built a reusable asset."**

![Modular Script Architecture](./modular_architecture.png)

## 📚 Overview

In the early stages of DevOps, scripts are often "Linear Monoliths"—a single file that runs from top to bottom. While simple, these scripts are impossible to test, hard to debug, and fragile.

**Functions** change the game. They allow you to encapsulate complex logic into a single, named command. Think of them as custom tools in your automation belt. Whether you are checking AWS credentials, or cleaning up Docker images, functions turn messy scripts into clean, modular orchestration.

---

## 💼 The Automation Why: The Microservice

**The Beginner's Question**: "Why write a function? I only use this code once."

**The Answer**: **Because you will use it once *today*.**
And then you'll copy-paste it 10 times, find a bug, and have to fix it in 10 places.

### The Microservice Analogy

Think of Functions as **Microservices within a Script**:

1.  **Linear Script = Monolith**
    - One giant file. If one variable breaks, the whole ship sinks.
    - Hard to read, hard to test.
2.  **Functions = Microservices**
    - **Isolated**: They have their own variables (`local`).
    - **Interface**: They take inputs (`$1`) and give outputs (`echo`).
    - **Reusable**: Write `check_disk_space` once, call it everywhere.

**DevOps Rule**:
- If you nest `if` inside `for` inside `if`, **extract a function**.
- If your script is > 50 lines, **group logic into functions**.

## 🎓 Learning Objectives

By the end of this module, you will:

- ✅ Master **Standard** vs **Function-Keyword** syntax.
- ✅ Implement the **`local` keyword** to prevent global state corruption.
- ✅ Orchestrate **Positional Parameters** within private function scopes.
- ✅ Capture outputs using **Command Substitution** (The Bash "Return" Pattern).
- ✅ Build professional-grade **Function Libraries** using `source`.
- ✅ Handle errors gracefully within modular units.

---

## 🏗️ The Anatomy of a Bash Function

### 1. Definition Styles

Bash offers two main ways to define functions. While they are mostly identical, knowing both is critical for reading legacy enterprise code.

| Style | Syntax | Notes |
| :--- | :--- | :--- |
| **Standard** | `my_func() { ... }` | Posix compliant, most common in industry. |
| **Keyword** | `function my_func { ... }` | Bash-specific, often easier for Python/JS devs to read. |

### 2. The Global Trap & The `local` Shield

By default, **variables in Bash are global**. This is the #1 cause of "magic bugs" in automation.

```bash
#!/usr/bin/env bash
TOTAL_FILES=100

function cleanup() {
    # 🛡️ local keeps this variable inside the function sandbox
    local TOTAL_FILES=0 
    echo "Inner cleaning... count is $TOTAL_FILES"
}

cleanup
echo "Global count is still: $TOTAL_FILES" # Stays 100
```

- **Production Pro-Tip**: Always treat global variables as `readonly` unless they are explicitly designed to be modified by functions. This prevents "Side-Effect Cascades" where changing a variable in one function breaks another.

---

## 🚀 Data Flow: Input & Results

### 1. Passing Arguments

Functions do not use named parameters in the definition. Instead, they use positional parameters (`$1`, `$2`, etc.), just like a standalone script.

```bash
function validate_env() {
    local env_name=$1
    local region=$2
    
    echo "[*] Validating $env_name in $region..."
    # Logic here...
}

# Calling the function
validate_env "Production" "us-east-1"
```

### 2. The "Return" Catch

In Bash, the `return` command **only returns an exit status (0-255)**, not data. To return a string or value, you must use `echo` and capture it via **Command Substitution**.

| Method | Best For | Call Syntax |
| :--- | :--- | :--- |
| `return 0` | Success/Failure status | `my_func && echo "Success"` |
| `echo $VAL` | Returning actual data | `RESULT=$(my_func)` |

---

## 🛠️ Professional Patterns for Automation

### Pattern A: The Resilient Logger

Centralized logging ensures consistency across your infrastructure logs.

```bash
function log_event() {
    local level=$1
    local msg=$2
    local color="\e[32m" # Default Green
    
    [[ "$level" == "ERROR" ]] && color="\e[31m" # Red for alert
    
    echo -e "${color}[$(date +'%H:%M:%S')] [$level] $msg\e[0m"
}

log_event "INFO" "Syncing S3 buckets..."
log_event "ERROR" "Connection timed out!"
```

### Pattern B: The Utility Library (`source`)

Pro-grade scripts are split into **Logic** and **Utilities**.

1. **`lib/utils.sh`**:

```bash
function check_root() {
    [[ $EUID -eq 0 ]] || { echo "Must run as root"; exit 1; }
}
```

1. **`deploy.sh`**:

```bash
source ./lib/utils.sh
check_root # Function from the library
```

---

## ⚡ Advanced Patterns

### 1. The Output Capture Pattern

Since functions only return exit codes, you "return" data by writing to stdout and capturing it.

```bash
function generate_token() {
    local seed=$1
    # Complex logic...
    echo "TOKEN_$(date +%s)_$seed"
}

# Capture the string result
MY_TOKEN=$(generate_token "dev-cluster")
echo "Active Token: $MY_TOKEN"
```

### 2. Functional Recursion

You can call a function from within itself. This is useful for walking directory trees or processing nested JSON structures.

```bash
function walk_dir() {
    for item in "$1"/*; do
        if [[ -d "$item" ]]; then
            echo "Dir: $item"
            walk_dir "$item" # RECURSIVE CALL
        else
            echo "File: $item"
        fi
    done
}
```

### 3. Graceful Failure (Set -e Context)

If a function fails, you often want the main script to stop.

```bash
function critical_task() {
    # If this fails, the whole script exits (if set -e is on)
    command_that_might_fail || return 1
}
```

### 4. Performance Note: Global References vs Subshells
Capturing output with `VAR=$(my_func)` is clean but spawns a **Process Subshell**, which is slow in tight loops (e.g., calling it 10,000 times).
For high-performance loops, you can write to a global variable (risky) or use **Name References** (`local -n` in Bash 4.3+).

---

## 🏆 Real-World DevOps Story: The Subshell Ghost

**The Scenario**: An automation engineer wrote a function to update a progress counter. The function was called inside a pipe: `tail -f logs | update_progress`.

**The Discovery**: The progress counter never changed! 

**The Lesson**: When you pipe to a function, it runs in a **Subshell**. Variables changed inside a subshell cannot pass back to the parent. Functions are powerful, but they are still bound by the laws of Linux processes.

---

## ❓ Interview Preparation (Shell Functions)

1. **Q: How do you return a string from a Bash function?**
   *A: You cannot use the `return` keyword for strings. You must `echo` the string and capture it using command substitution: `VAR=$(my_function)`.*

2. **Q: What happens if you define a function with the same name as a built-in command?**
   *A: The function takes precedence. If you name a function `ls`, running `ls` will execute your function instead of the binary. Use `command ls` to bypass the function.*

3. **Q: How can you export a function so it's available in sub-shells?**
   *A: Use `export -f function_name`.*

4. **Q: What is the difference between `$@` and `$*` inside a function?**
   *A: Within quotes, `"$@"` expands to separate arguments (`"arg1" "arg2"`), while `"$*"` expands to a single string (`"arg1 arg2"`).*

5. **Q: How do you list all defined functions in the current session?**
   *A: Use the command `declare -F` to see names, or `declare -f` to see definitions.*

---

## 📝 Knowledge Check

1. **Which keyword creates a "sandbox" for variables inside a function?**
   - [ ] a) `private`
   - [x] b) `local`
   - [ ] c) `block`

2. **What is the maximum value a `return` command can send back?**
   - [ ] a) Infinity
   - [ ] b) 1024
   - [x] c) 255

3. **How do you access the TOTAL number of arguments passed to a function?**
   - [ ] a) `$TOTAL`
   - [x] b) `$#`
   - [ ] c) `$@`

4. **What command is used to load an external function library?**
   - [ ] a) `import`
   - [x] b) `source` or `.`
   - [ ] c) `load`

5. **True or False: A function can call itself (Recursion).**
   - [x] a) True
   - [ ] b) False

---

## 🔗 Next Steps

Ready to handle data streams and advanced file descriptors?

Proceed to: **[Strict Mode & Safety](../06-Strict-Mode-Safety/README.md)** →
