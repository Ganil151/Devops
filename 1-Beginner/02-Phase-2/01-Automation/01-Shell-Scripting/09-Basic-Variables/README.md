# 📦 Basic Variables (State & Abstraction)
> **"Hardcoding is a technical debt you pay every day. Variables are the currency of automation."**
![Shell Variable Mechanics](./variable_mechanics.svg)
## 📚 Overview
Variables are the foundation of dynamic infrastructure. In DevOps, we use them to store API keys, target server IPs, deployment tags, and temporary compute results. Without variables, every script would be a static, fragile set of commands that breaks the moment the environment changes. This module covers the essential mechanics of shell state management.
## 🎓 Learning Objectives
By the end of this module, you will:
- ✅ Master the **Assignment Syntax** (and why spaces break your script).
- ✅ Understand **Parent-Child Inheritance** using `export`.
- ✅ Decode **Quoting Rules**: Single (`'`) vs Double (`"`) vs Backticks (`` ` ``).
- ✅ Leverage **Parameter Expansion** for smart defaults (`${var:-fallback}`).
- ✅ Use **Command Substitution** to store command output in variables.
---
## 🏗️ The Rules of Engagement
### 1. The Syntax (No Spaces!)
In Bash, spaces are command delimiters. Adding a space around `=` changes the meaning entirely.
| Syntax | Action |
|--------|--------|
| `PORT=80` | **✅ Assignment**: Stores 80 in PORT. |
| `PORT = 80` | **❌ Executing**: Tries to run a command named `PORT` with arguments `=` and `80`. |
| `PORT= 80` | **❌ Setting Env**: Tries to run a command named `80` with an empty variable `PORT`. |
### 2. Quoting: The Great Decider
The type of quotes you use determines whether a variable is "expanded" or treated as literal text.
```bash
USER="Ganil"
# 🟢 Double Quotes: "Expansion allowed"
echo "Hello $USER"  # Output: Hello Ganil
# 🔴 Single Quotes: "Strict Literal"
echo 'Hello $USER'  # Output: Hello $USER
# ⚙️ Backticks / $(...): "Command Execution"
NOW=$(date)
echo "Current time is $NOW"
```
---
## 🚀 Advanced Parameter Expansion (DevOps Gold)
Senior engineers don't just use `$VAR`. They use expansion logic to handle edge cases.
| Syntax | Description | Use Case |
|--------|-------------|----------|
| `${VAR:-default}` | If VAR is empty, use `default`. | **CI/CD Default Regions** |
| `${VAR:?error}` | If VAR is empty, **STOP** script and print error. | **Missing API Keys** |
| `${#VAR}` | Returns the length of the string. | **Validation Checks** |
| `${VAR/old/new}` | Replace first occurrence of `old` with `new`. | **Path Rewriting** |
**Example (Defensive Automation):**
```bash
# Crash if the Target Directory isn't provided
TARGET_DIR=${1:?"Error: You must provide a target directory!"}
# Use 'development' environment if none specified
ENV=${ENVIRONMENT:-"development"}
```
---
## 🌍 The Hierarchy of Scope
Variables do not automatically move between scripts unless you explicitly **export** them.
1. **Local Variables**: Only available in the current shell process.
2. **Environment Variables**: Available to the current process AND all child processes (scripts it runs).
```bash
# Set a local variable
API_KEY="secret123"
# Make it available to sub-scripts
export API_KEY
```
---
## 📑 The Variable Cheat Sheet
| Syntax | Meaning | Context |
|--------|---------|---------|
| `VAR=val` | Assignment | String or Integer |
| `$VAR` | Reference | Access the value |
| `${VAR}` | Safe Reference | Avoids glue-word collisions |
| `export V` | Environment | Pass to child processes |
| `unset V` | Delete | Remove from memory |
| `readonly V`| Immutable | Constant values |
---
## 🏆 Real-World DevOps Story
### � **The Empty Variable Catastrophe**
**The Scenario**: A junior engineer wrote a cleanup script: `rm -rf $TMP_DIR/*`. One day, the script ran in a new environment where `$TMP_DIR` wasn't set.
**The Discovery**:
Because `$TMP_DIR` was empty, the shell expanded the command to: `rm -rf /*`.
**The Fix**:
Senior engineers use defensive parameter expansion.
`rm -rf ${TMP_DIR:? "Error: TMP_DIR is not set!"}/*`
Now, if the variable is empty, the script exits immediately with an error message instead of deleting the root filesystem.

---
## 📝 Knowledge Check
1. **What is the result of `echo 'Value: $PATH'`?**
   - [ ] a) It prints the system path
   - [x] b) It prints literally `Value: $PATH`
   - [ ] c) It causes a syntax error
2. **Which syntax sets a default value if a variable is empty?**
   - [ ] a) `${VAR?default}`
   - [x] b) `${VAR:-default}`
   - [ ] c) `${VAR=+default}`
3. **How do you make a variable available to a sub-script?**
   - [ ] a) `local VAR`
   - [ ] b) `set VAR`
   - [x] c) `export VAR`
**Answers**: 1-b, 2-b, 3-c
## 🔗 Next Steps
Continue to: **[Vim Crash Course](../10-Vim-Crash-Course/README.md)** →
