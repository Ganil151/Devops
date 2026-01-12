# 🧩 Functions (The Art of Modularity)
> **"Don't Repeat Yourself (DRY). If you type the same logic twice, you've inherited a maintenance nightmare. If you make it a function, you've built a tool."**
![Modular Script Architecture](./modular_architecture.svg)
## 📚 Overview
Automation scripts often start as a simple list of commands. But as complexity grows scripts become unreadable "Monoliths." **Functions** allow you to group code into named, logical units. They act like "Scripts within Scripts," allowing you to solve a problem once and reuse the solution a hundred times across your infrastructure.
## 🎓 Learning Objectives
By the end of this module, you will:
- ✅ Define **Standard** vs **C-Style** function syntax.
- ✅ Protect the global state using the **`local` keyword**.
- ✅ Map **Function arguments** and understand local positional scoping.
- ✅ Capture data using **Command Substitution** instead of return values.
- ✅ Build and source external **Function Libraries** for cross-script reuse.
---
## 🏗️ Function Architecture: Scoping & Return
### 1. The Global Trap (`local`)
By default, every variable in Bash is **Global**. If you change a variable inside a function without `local`, you change it for the entire script. Always declare variables inside functions with `local`.
### 2. Passing Data
Functions use the same positional variables as scripts (`$1`, `$2`), but they are **private** to the function.
- **`$1` inside function**: First arg passed TO the function.
- **`$1` outside function**: First arg passed TO the script.
---
## 🚀 Practical Examples for Automation
### Example A: The Professional Logger
Instead of using `echo` everywhere, use a central logging function that adds timestamps and status colors.
```bash
function log_info() {
    local message="$1"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ℹ️ INFO: $message"
}
log_info "Starting database backup..."
```
### Example B: The Sourcing Flow (Library)
Keep your common tasks (AWS logins, SSH checks) in a central `utils.sh` and "import" them.
```bash
# In deploy.sh
source ./utils.sh
# Now utils functions are available
check_connection "api.prod.com"
```
---
## 📑 The Functions Cheat Sheet
| Task | Syntax | Example |
|------|--------|---------|
| **Define** | `func_name() { ... }` | `cleanup() { ... }` |
| **Call** | `func_name` | `cleanup` |
| **Arguments**| `func_name arg1` | `backup /var/log` |
| **Local Var**| `local VAR=val` | `local port=80` |
| **Return Status**| `return 0-255` | `return 0` |
| **Source Lib**| `source file.sh` | `. ./config.sh` |

---
## 🏆 Real-World DevOps Story
### 💡 **The Variable Collision Disaster**
**The Scenario**: An engineer had a global variable `RETRIES=3`. They wrote a cleanup function that also used a variable called `RETRIES=0` to loop.
**The Discovery**:
Because they didn't use `local`, the function overwrote the global `RETRIES`. When the main script tried to retry a critical deployment, it failed instantly because the value was now 0.
**The Fix**:
Always use `local` inside functions. It creates a "sandbox" for your variables, ensuring the main script remains stable.

---
## 📝 Knowledge Check
1. **Which keyword ensures a variable is only used inside a function?**
   - [ ] a) `static`
   - [x] b) `local`
   - [ ] c) `private`
2. **How do you access the first argument passed TO a function?**
   - [x] a) `$1`
   - [ ] b) `$arg1`
   - [ ] c) `$F1`
3. **What is the command to import functions from another file?**
   - [ ] a) `import`
   - [x] b) `source`
   - [ ] c) `include`
**Answers**: 1-b, 2-a, 3-b
## 🔗 Next Steps
Continue to: **[Conditionals](../15-Conditionals/README.md)** →
