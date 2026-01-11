# ⌨️ User Input (Interactive & Parameterized Scripts)

> **"A script that talks to itself is fine. A script that talks to you is powerful. A script that listens to you is professional."**

![Shell Input Architecture](./input_channels_mapping.svg)

## 📚 Overview

Automation doesn't always mean "zero touch." Sometimes your logic requires external context: a target environment name, a dynamic version number, or a manual confirmation ("Are you sure?"). Bash provides two primary mechanisms for input: **Positional Arguments** (passed at startup) and the **Read** command (interactive runtime prompts).

---

## 🎓 Learning Objectives

By the end of this module, you will:

- ✅ Master **Positional Parameter Mapping** (`$1` to `$n`).
- ✅ Build interactive workflows with `read` (Secure, Timed, and Limited).
- ✅ Implement robust **Input Validation** (Handle missing or bad data).
- ✅ Learn the **Shift** mechanic for processing argument queues.
- ✅ Understand the critical difference between `$@` and `"$@"`.

---

## 🏎️ 1. Positional Arguments (Parameters)

Arguments are the standard "DevOps way." They allow your scripts to be used in pipelines (Jenkins, GitLab CI) where no human is present to type answers.

### The Special Variable Array:
| Variable | Represents | Why it's useful |
|----------|------------|-----------------|
| **`$0`** | Script Path | Used for "Usage" and error messages. |
| **`$1` - `$9`**| Arguments | The actual data (e.g., `./backup.sh /var/www`). |
| **`$#`** | Argument Count| **CRITICAL** for checking if the user forgot input. |
| **`$@`** | All Arguments | Used to loop through many inputs easily. |
| **`$$`** | Process ID | Creating unique temp files (e.g., `/tmp/log.$$`). |

### The Power of `shift`:
Used to process arguments one-by-one in a loop.
```bash
# Example: handling any number of files
while [ $# -gt 0 ]; do
  echo "Processing file: $1"
  shift # Moves $2 to $1, reduces $#
done
```

---

## 💬 2. Interactive Input (`read`)

The `read` command pauses execution and waits for user input from Keyboard/Stdin.

### Professional `read` Flags:
- **`-p "Prompt: "`**: The most common way to display a message on the same line.
- **`-s` (Silent)**: Hides the characters as they are typed. **Essential for passwords.**
- **`-t <sec>` (Timeout)**: Continues if the user doesn't answer in time.
- **`-n <chars>`**: Stops after X characters (useful for `[y/n]` prompts).
- **`-a <array>`**: Reads input into a Bash array.

```bash
# Pro Interaction Example
read -t 5 -p "Confirm deployment to production? [y/N] " confirm
confirm=${confirm:-n} # Default to 'n' if timeout or empty
```

---

## 🛡️ Input Security & Validation

**Rule**: Never trust user input.

### 1. The Argument Check
Always verify that required inputs exist before running destructive code.
```bash
# Defensive coding
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <source_dir> <target_bucket>"
    exit 1
fi
```

### 2. The Quote Trap
Always wrap positional variables in double quotes!
```bash
# ❌ DANGEROUS: Fails if path has spaces
ls $1

# ✅ SECURE: Handles any characters safely
ls "$1"
```

---

## 🏆 Real-World DevOps Case Study

### 🚨 **The Ghost Target Incident**

**The Scenario**: A cleanup script was designed to clear old logs: `./cleanup.sh /var/log/app`. 
Inside: `rm -rf "$1/*"`

**The Bug**: An engineer ran `./cleanup.sh` (zero arguments). 
Bash evaluated `"$1/*"` as `""/*` → effectively `/*`. 
Because there was no validation, the script attempted to delete the root filesystem!

**The Fix**:
```bash
# .1. Validate Count
[[ -z "$1" ]] && { echo "Error: Path required"; exit 1; }

# .2. Validate Existence
[[ ! -d "$1" ]] && { echo "Error: $1 is not a directory"; exit 1; }

# .3. Execution
rm -rf "${1:?}/"*
```

---

## 🎓 Interview Questions

#### Q1: What is the difference between `$*` and `$@`?
<details>
<summary>Click to reveal answer</summary>
When quoted, `"$*"` treats all arguments as **one single string** (separated by first char of IFS). `"$@"` treats each argument as a **separate entity**. In DevOps loops, you almost always want `"$@"` to handle filenames with spaces correctly.
</details>

#### Q2: How do you read a secret key without showing it on the screen?
<details>
<summary>Click to reveal answer</summary>
Use `read -s`. It disables terminal echo for that specific input. Always follow it with `echo` to move to a new line after the input is done.
</details>

#### Q3: How do you handle optional arguments?
<details>
<summary>Click to reveal answer</summary>
Use Parameter Expansion: `VAR=${1:-default_value}`. If `$1` is missing, `VAR` gets "default_value".
</details>

---

## 📝 Knowledge Check

1. **How do you get the number of arguments passed to a script?**
   - [ ] a) `$*`
   - [x] b) `$#`
   - [ ] c) `$@`
   - [ ] d) `$N`

2. **Which flag makes `read` timeout after 10 seconds?**
   - [ ] a) `-m 10`
   - [x] b) `-t 10`
   - [ ] c) `-w 10`
   - [ ] d) `-x 10`

3. **What does the command `shift` do?**
   - [ ] a) Deletes the script
   - [ ] b) Capitalizes all arguments
   - [x] c) Moves positional parameters one index to the left
   - [ ] d) Changes the shell environment

4. **Why is `read -p` preferred over `echo "..." && read`?**
   - [ ] a) It's faster
   - [x] b) It keeps the prompt and input on the same line
   - [ ] c) It's more secure
   - [ ] d) It's required in Zsh

**Answers**: 1-b, 2-b, 3-c, 4-b

## 🔗 Additional Resources
- [Bash Input/Output Redirection](https://tldp.org/LDP/abs/html/io-redirection.html)
- [Parsing Arguments with Getopts](http://wiki.bash-hackers.org/howto/getopts_tutorial)

---
**📌 Pro Tip**: Use the **`select`** command to build quick interactive menus without writing complex `if/else` loops!
```bash
select env in prod dev staging; do
  echo "You selected $env"; break
done
```
