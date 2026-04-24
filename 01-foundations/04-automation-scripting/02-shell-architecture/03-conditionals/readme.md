# 🔀 Conditionals: The Logic of Automation

> **"A script without conditionals is just a list. A script with conditionals is a decision-maker capable of autonomous action."**

![Conditional Logic Flow](./conditional-logic-flow.png)

## 📚 Overview

Conditionals are the "Brain" of your automation. They allow your script to perceive its environment and adapt its behavior in real-time. Instead of running a deployment blindly, a professional script asks: "Is the database reachable?", "Is this file already backed up?", or "Does the current user have root privileges?".

### Historical Context & Evolution

In the early days of Unix, the shell relied heavily on the external `test` command (often symlinked as `[`). This legacy approach was fraught with quoting issues and limited functionality. Modern Bash introduced the `[[ ... ]]` keyword and `(( ... ))` arithmetic context, drawing inspiration from the Korn Shell (ksh). This evolution transformed shell scripting from a simple glue language into a robust automation tool, allowing for safe regex matching `[[ ... =~ ... ]]`, complex logical grouping, and C-style arithmetic loops. Today, mastering these modern constructs is essential for writing secure, POSIX-compliant (where needed), and resilient DevOps pipelines.

---

## 💼 The Automation Why: The Gatekeeper

**The Beginner's Question**: "Why check? The file *should* be there."

**The Answer**: **Assume the world is broken.**
In a distributed system, networks fail, disks fill up, and permissions change. A script that doesn't check conditions is a script that deletes `home` directory because `cd` failed.

### The Bouncer Analogy

Think of an `if` statement as a **Club Bouncer**:

1.  **File Check (`-f ticket.pdf`)**: "Do you have a ticket?"
2.  **String Check (`$USER == "vip"`)**: "Is your name on the list?"
3.  **Arithmetic Check (`$AGE >= 21`)**: "Are you old enough?"
4.  **Exit (`else exit 1`)**: "Sorry, access denied."

**DevOps Rule**:
- **70%** of your script code should be "The Bouncer" (Validation).
- **30%** should be the actual party (Execution).

---

## 🎓 Learning Objectives

By the end of this module, you will:

1. ✅ **Master the Triple-Option `if`/`elif`/`else` anatomy.**
    - **Why**: To handle complex decision trees (e.g., success, partial failure, critical failure).
    - **Use Case**: A backup script that retries connectivity before giving up.

2. ✅ **Understand the Comparison Partition: Strings (`==`) vs Integers (`-eq`).**
    - **Why**: Providing the wrong type to an operator is a frequent source of logic bugs.
    - **Use Case**: Distinguishing between version "1.10" (string) and the number 10 (integer).

3. ✅ **Leverage File Test Operators (`-f`, `-d`, `-x`, `-s`) for system auditing.**
    - **Why**: Scripts rarely operate in a vacuum; they interact with the filesystem.
    - **Use Case**: Ensuring a config file exists `-f` and is readable `-r` before parsing.

4. ✅ **Adopt the Superior `[[ ]]` Syntax for safer, modern Bash code.**
    - **Why**: It prevents critical "word-splitting" errors that crash production scripts.
    - **Use Case**: Handling filenames with spaces, like `"User Data.txt"`.

5. ✅ **Implement Arithmetic `(( ))` Evaluation for mathematical logic.**
    - **Why**: Native integer handling is faster and more readable than external calls to `expr`.
    - **Use Case**: Calculating retry counters or checking disk usage percentages.

6. ✅ **Master Case Switch Patterns for complex flags and menu handling.**
    - **Why**: `if/elif` chains become unreadable after 3+ conditions. `case` scales cleanly.
    - **Use Case**: Processing command-line arguments (`--install`, `--remove`, `--update`).

---

## 🏗️ Logic Architecture: Choosing Your Brackets

Professional Bash relies on three distinct evaluation engines. Choosing the wrong one is the #1 cause of "Silent Failability" in scripts.

### 1. The Comparison Matrix

| Feature | Single `[ ]` | Double `[[ ]]` | Parens `(( ))` |
| :--- | :--- | :--- | :--- |
| **Logic Engine** | External Cmd | Bash Keyword | Math Context |
| **Compatibility** | POSIX / Sh | Bash / Zsh | Bash / Zsh |
| **Logical Ops** | `-a`, `-o` | `&&`, `\|\|` | `&&`, `\|\|` |
| **Feature Set** | Basic Checks | Regex, Globs | Math, Bits |

### 2. The Modern Standard: `[[ ... ]]` (Strings & Files)

Double brackets are not just "newer"; they are **structurally different**. They disable the shell's field splitting and pathname expansion, allowing variables to be used without quotes safely.

- **Wildcard/Glob Matching**: Use `==` with unquoted patterns.

  ```bash
  [[ $hostname == nodes-* ]] && echo "This is a cluster node"
  ```

- **Regex Evaluation**: Use `=~`. Captured groups populate the `BASH_REMATCH` array.

  ```bash
  if [[ $version =~ ^v([0-9]+)\. ]]; then
      echo "Major version: ${BASH_REMATCH[1]}"
  fi
  ```

### 3. The Math Context: `(( ... ))` (Integers)

Never use `[[ $x -gt $y ]]` for pure numbers. Use the arithmetic engine; it is faster and supports C-style logic.

- **Ternary Logic**: `(( result = condition ? 1 : 0 ))`. Great for compact status checks.
- **Base Interpretation**: `(( 16#FF == 255 ))`. Essential for decoding hardware or network statuses.

### 4. Common Pitfalls: The Octal & Float Trap

1. **Floating Point**: Bash performs **integer math only**. Attempting `(( 1.5 > 1 ))` will crash your script. Use `bc` for floating-point comparisons.
2. **The Octal Ghost**: A leading zero (`08`, `09`) triggers Octal interpretation (Base-8). Since 8 and 9 don't exist in Base-8, the script will error.
   - **Defense**: Force Base-10 with `10#`.

   ```bash
   # Safe date check
   if (( 10#$(date +%m) > 6 )); then
       echo "H2 is here"
   fi
   ```

---

## 🚀 Professional Patterns for Automation

Writing scripts that "work" is easy. Writing scripts that are maintainable, readable, and robust requires adopting specific design patterns.

### Pattern A: The Guard Clause (Fail Fast)

**Concept**: Instead of wrapping your entire script in a giant `if` block, check for failure conditions at the very top and exit immediately. This keeps the "happy path" code unindented and easy to read.

**Syntax Note**: curly braces `{ ...; }` group commands, allowing you to run multiple actions (echo + exit) after the `||` operator.

```bash
# ❌ Anti-Pattern: Arrow Code
if [[ $EUID -eq 0 ]]; then
    if command -v docker &> /dev/null; then
        # Actual logic starts here...
        echo "Running..."
    fi
fi

# ✅ Professional Pattern: Guard Clauses
[[ $EUID -eq 0 ]] || { echo "❌ Error: Must run as root"; exit 1; }
command -v docker &> /dev/null || { echo "❌ Error: Docker not installed"; exit 1; }

# Actual logic starts here, flat and clean
echo "Running..."
```

### Pattern B: Short-Circuit Logic (`&&` and `||`)

Use logical operators for "one-liner" dependency chains. This is best for atomic operations where if step 1 fails, step 2 *must not* happen.

- **Success Link (`&&`)**: "Do X, and ONLY if X succeeds, do Y."
  ```bash
  # Only try to copy if the directory creation worked
  mkdir -p /backup && cp -r /data /backup/
  ```
- **Failure Link (`||`)**: "Do X, and ONLY if X fails, do Y."
  ```bash
  # Set a default variable if one isn't provided
  [[ -n "$Target_Env" ]] || Target_Env="dev"
  ```

### Pattern C: Advanced Case Switch (Globs & Or)

The `case` statement is powerful because it supports **Glob patterns** (wildcards), making it far more flexible than a simple switch.

```bash
read -p "Deploy version? (e.g., v1.0, v2.beta): " version

case "$version" in
    v1.*) # Matches v1.0, v1.2, v1.99
        echo "✅ Deploying Stable Legacy Version..." ;;
    v2.*|beta) # Matches v2.anything OR "beta"
        echo "⚠️  Deploying Beta Version (Experimental)..." ;;
    *)
        echo "❌ Invalid version format."
        exit 1 ;;
esac
```

### Pattern D: Nested Conditionals vs Flat Logic

Deeply nested `if` statements are hard to read and debug. Flattening your logic makes the flow linear.

**Refactor This:**

```bash
if [[ -f config.yaml ]]; then
    if [[ $USER == "admin" ]]; then
        echo "Deploying..."
    fi
fi
```

**To This:**

```bash
[[ ! -f config.yaml ]] && exit 1  # Check 1
[[ $USER != "admin" ]] && exit 1  # Check 2

echo "Deploying..."               # Action
```

### Pattern E: The "Default Value" Shorthand

While technically **Parameter Expansion**, this pattern replaces verbose `if` blocks for setting defaults.

**Verbose Conditional:**

```bash
if [[ -z "$1" ]]; then
    NAME="World"
else
    NAME="$1"
fi
```

**Professional One-Liner:**

```bash
# Sytax: ${VARIABLE:-DEFAULT_VALUE}
NAME="${1:-World}"
echo "Hello, $NAME"
```

*This checks if `$1` is set and non-null. If it is, use it. If not, use "World".*

---

## ⚡ Advanced Techniques: Beyond Simple Checks

### 1. Idempotency with Time-Based Checks (`-nt`, `-ot`)

In DevOps, "Idempotency" means a script can run multiple times without unintended side effects. Using time-based file comparisons is key for this (e.g., "Only compilation if source is newer than binary").

| Operator | Meaning | Use Case |
| :--- | :--- | :--- |
| `file1 -nt file2` | **N**ewer **T**han | Rebuild logic (Code > Binary) |
| `file1 -ot file2` | **O**lder **T**han | Backup rotation / Archiving |

```bash
# Only rebuild the app if 'src/main.c' is newer than 'bin/app'
if [[ src/main.c -nt bin/app ]]; then
    echo "🔄 Source changed. Recompiling..."
    gcc src/main.c -o bin/app
else
    echo "✅ Application is up to date."
fi
```

### 2. Regex Capturing with `BASH_REMATCH`

When you use the regex operator `=~`, Bash doesn't just return True/False. It captures the matching groups into a special array called `BASH_REMATCH`.

- `${BASH_REMATCH[0]}`: The entire matching string.
- `${BASH_REMATCH[1]}`: The first capture group `(...)`.
- `${BASH_REMATCH[2]}`: The second capture group, etc.

#### Example: Parsing a Config String

```bash
config="server_port=8080"
regex="^server_port=([0-9]+)$"

if [[ $config =~ $regex ]]; then
    echo "Server is valid."
    echo "Port detected: ${BASH_REMATCH[1]}" # Outputs: 8080
else
    echo "Invalid config format."
fi
```

---

## 🏆 Real-World DevOps Story: The Empty String Disaster

**The Scenario**: A script had an optional variable `CLEANUP_DIR`. The engineer wrote `if [ $CLEANUP_DIR == "/tmp" ]`.

**The Discovery**: One day, the variable was empty due to a failed upstream API call. The single bracket `[` evaluated this as `if [ == "/tmp" ]`, which is a syntax error that crashed the entire deployment pipeline.

**The Fix**: They switched to `[[ "$CLEANUP_DIR" == "/tmp" ]]`. Double brackets handle the empty variable gracefully, treating it as `"" == "/tmp"` (Result: False), which allowed the script to continue running safely.

### Anecdote 2: The Octal Trap

**The Scenario**: A timestamp variable `MONTH` was extracted as "08" (August). The script used `(( MONTH < 9 ))` to check if it was early in the year.

**The Crash**: The script failed with an "invalid octal digit" error.

**The Reason**: In Bash arithmetic `(( ... ))`, numbers starting with `0` are treated as Octal (Base-8). Does "08" exist in Base-8? No (digits are 0-7).

**The Fix**: Explicitly force base-10 interpretation: `(( 10#$MONTH < 9 ))`.

---

## ❓ Interview Preparation (Conditionals)

1. **Q: What is the difference between `[` and `[[`?**
   - *A: `[` is an external command (frequently a symlink to `test`), while `[[` is a Bash keyword. `[[` is more powerful as it handles empty variables without crashing, supports regex matching (`=~`), and doesn't require quoting variables to prevent word-splitting.*

2. **Q: How do you check if a string is NOT empty?**
   - *A: Use the `-n` operator: `[[ -n "$MY_VAR" ]]`. Conversely, `-z` checks if a string is zero-length (empty).*

3. **Q: How do you perform a "regex" match in a condition?**
   - *A: Use the `=~` operator inside double brackets. Example: `[[ $IP =~ ^[0-9]{1,3}\. ]]`.*

4. **Q: What does the `-f` operator check?**
   - *A: It checks if a path exists AND if it is a regular file (not a directory or a device file).*

5. **Q: How can you check the exit status of the previous command?**
   - *A: Using the `$?` variable. A value of `0` means success, while anything else (1-255) indicates an error.*

6. **Q: What happens if you use `set -e` in a script with conditionals?**
   - *A: `set -e` causes the script to exit immediately if any command returns a non-zero status. However, built-in conditionals like `if` statements or `[[ ... ]]` checks are **exempt** from this rule, allowing you to handle the failure logic yourself without the script crashing.*

7. **Q: Can you combine logical AND/OR inside a `case` statement?**
   - *A: Not directly in the pattern matcher like `if [[ a && b ]]`. However, you can use the pipe `|` for OR logic (e.g., `start|up)`. For logical AND, you typically use nested `if` or `case` blocks inside the match.*

---

## 📝 Knowledge Check

1. **Which operator is used inside `(( ))` to check for equality?**
   - [ ] a) `-eq`
   - [x] b) `==`
   - [ ] c) `=`
   *Explanation: Double parentheses use C-style arithmetic operators, where `==` is comparison. `-eq` is for `[` or `[[`.*

2. **What does `[[ -s "/var/log/app.log" ]]` check?**
   - [ ] a) If the file belongs to the 'system' user
   - [ ] b) If the file exists
   - [x] c) If the file exists AND has a size greater than zero (not empty)
   - *Explanation: `-s` stands for "size". It is true if file size > 0.*

3. **How do you write an OR condition inside `[[ ]]`?**
   - [ ] a) `-o`
   - [x] b) `||`
   - [ ] c) `|`
   *Explanation: `||` is the standard logical OR in double brackets. `-o` is deprecated legacy syntax for `[`.*

4. **Which file test operator checks if a directory exists?**
   - [x] a) `-d`
   - [ ] b) `-dir`
   - [ ] c) `-f`
   *Explanation: `-d` (directory) checks for folders. `-f` is for regular files.*

5. **What is the incorrect way to check if a file is executable?**
   - [ ] a) `[[ -x script.sh ]]`
   - [x] b) `[[ -e script.sh ]]`
   - [ ] c) `test -x script.sh`
   *Explanation: `-e` only checks if the file *exists*, not if it is *executable*. `-x` checks permissions.*

6. **True or False: A case statement must end with `esac`.**
   - [x] a) True
   - [ ] b) False
   - *Explanation: Just as `if` ends with `fi`, `case` ends with `esac` (case spelled backwards).*

---

## 🔗 Next Steps

Now that your script can think, give it a task to repeat!

Proceed to: **[Loops & Processing](../04-loops-and-processing/readme.md)** →
