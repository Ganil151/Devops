# 🐚 Shell Scripting Fundamentals Reference
*Version 1.0 | Mastering the CLI Logic Engine*

---

## 📖 Overview
Shell scripting is the automated execution of a sequence of commands for a shell (command-line interpreter). While Bash is the standard, understanding the underlying POSIX standards and shell execution lifecycle is critical for reliable infrastructure automation.

---

## 🏗️ Core Syntax & Variable Mechanics

### 1. Variables & Scope
- **Local Variables**: Defined within a script or function. `VAR=value`
- **Environment Variables**: Exported to child processes. `export VAR=value`
- **Special Parameters**:
  - `$0`: Name of the script.
  - `$1..$9`: Positional parameters (arguments).
  - `$#`: Number of arguments.
  - `$*` / `$@`: All arguments.
  - `$?`: Exit status of the last command (0 = Success, Non-zero = Failure).
  - `$$`: Process ID (PID) of the current shell.

### 2. Quoting & Expansion
- **Single Quotes (' ')**: Literal string; no expansions.
- **Double Quotes (" ")**: Allows variable (`$VAR`) and command (`$(cmd)`) expansion.
- **Backticks (``) / `$( )`**: Command substitution. Always prefer `$( )` for nesting.

---

## ⚙️ Control Structures (Under the Hood)

### Logical Operators
- `&&` (AND): Run second command only if first succeeds.
- `||` (OR): Run second command only if first fails.

### Comparisons (`test` / `[ ]` / `[[ ]]`)
- `[[ ]]`: Bash extension; supports `&&`, `||`, and regex matching (`=~`).
- `-z $VAR`: True if string is empty.
- `-f $FILE`: True if path is a regular file.
- `-d $DIR`: True if path is a directory.
- `$A -eq $B`: Numeric equality.
- `$A == $B`: String equality.

---

## 🚀 Advanced Execution Logic

### Redirection & Piping
- `>`: Overwrite file.
- `>>`: Append to file.
- `2>`: Redirect Standard Error (stderr).
- `&>`: Redirect both stdout and stderr.
- `|`: Pipes stdout of command 1 to stdin of command 2.

### Subshells `( )` vs. Blocks `{ }`
- **`( )`**: Executes commands in a separate subshell process. Variables created inside do not affect the parent shell.
- **`{ }`**: Executes commands in the current shell context.

---

## 🛡️ SRE Standard Checklist
- [ ] **Shebang**: Always start with `#!/bin/bash` or `#!/bin/env bash`.
- [ ] **Exit on Error**: Use `set -e` to stop script on any failure.
- [ ] **Unset Variable Check**: Use `set -u` to prevent logic errors from empty variables.
- [ ] **Log Everything**: Pipe critical outputs to a log file with timestamps.

---

## ❓ Interview "Deep-Cut" Questions
1. **Explain the difference between `$*` and `$@` when used inside double quotes.**
2. **How does the "Short-Circuit" logic of `&&` and `||` differ from traditional `if` statements?**
3. **What is the significance of the `IFS` (Internal Field Separator) variable?**
4. **Describe the process of a "Heredoc" (`<<EOF`) and its common use cases in configuration automation.**
5. **What is the difference between `source script.sh` and `./script.sh` in terms of memory and process space?**

---
**Next Step**: [Bash Architecture & Signals →](./bash-architecture-ref.md)
