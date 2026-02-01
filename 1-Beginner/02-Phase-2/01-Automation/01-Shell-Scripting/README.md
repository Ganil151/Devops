# Shell Scripting: The Foundation

> **"Before you can automate the cloud, you must master the terminal. Shell scripting is the bedrock of DevOps—it's how we interact with the OS, manage files, and glue tools together."**

## 🗺️ Curriculum Architecture

We have consolidated the modules into three professional tiers, matching the structure of our Python and Go tracks.

### 🔹 Part 1: Shell Foundations (The Syntax)
*Basic navigation, file management, and core tools.*

*   **[01. Introduction](./Part-01-Shell-Foundations/01-Introduction/README.md)**: Why Bash?
*   **[02. Terminal & Navigation](./Part-01-Shell-Foundations/02-Terminal-and-Navigation/README.md)**: Moving around the OS.
*   **[03. File Manipulation](./Part-01-Shell-Foundations/03-File-Manipulation/README.md)**: Creating, copying, searching (`grep`, `find`).
*   **[04. Man Pages](./Part-01-Shell-Foundations/04-Man-Pages-and-Help/README.md)**: Learning how to learn.
*   **[05. Vim Basics](./Part-01-Shell-Foundations/05-Vim-Basics/README.md)**: Editing text on remote servers.
*   **[06. Permissions](./Part-01-Shell-Foundations/06-Permissions/README.md)**: `chmod` and `chown`.
*   **[07. Variables](./Part-01-Shell-Foundations/07-Basic-Variables/README.md)**: Storing data.
*   **[08. Programs & Commands](./Part-01-Shell-Foundations/08-Programs-and-Commands/README.md)**: Built-ins, Aliases, and PATH.

### 🔸 Part 2: Shell Architecture (The Logic)
*Programming logic within the shell.*

*   **[01. Arithmetic & Metrics](./Part-02-Shell-Architecture/01-Arithmetic-and-Metrics/README.md)**: Math and `bc`.
*   **[02. User Input](./Part-02-Shell-Architecture/02-User-Input/README.md)**: `read` and interactive scripts.
*   **[03. Conditionals](./Part-02-Shell-Architecture/03-Conditionals/README.md)**: `if`, `else`, and logic gates.
*   **[04. Loops & Processing](./Part-02-Shell-Architecture/04-Loops-and-Processing/README.md)**: Handling lists and files.
*   **[05. Functions & Scope](./Part-02-Shell-Architecture/05-Functions-and-Scope/README.md)**: Modular scripting.
*   **[06. Strict Mode & Safety](./Part-02-Shell-Architecture/06-Strict-Mode-Safety/README.md)**: Writing bulletproof code.

### 🚀 Part 3: System Drafting (The Automation)
*Building real-world scripts and advanced I/O.*

*   **[01. Scripting Basics](./Part-03-System-Drafting/01-Scripting-Basics/README.md)**: Your first real scripts.
*   **[02. Advanced I/O](./Part-03-System-Drafting/02-Advanced-IO/README.md)**: Redirection, pipes, and descriptors.

---

## 🏢 Reference Library
*Deep-dive documentation for at-a-glance problem solving.*

*   **[Shell Fundamentals](./REFERENCE/Shell-Fundamentals-Ref.md)**: Variables, quoting, and basic execution.
*   **[Bash Architecture](./REFERENCE/Bash-Architecture-Ref.md)**: Subshells, signals, and job control.
*   **[Stream Editing & Filtering](./REFERENCE/Stream-Editing-Filtering-Ref.md)**: Grep, Sed, and Awk manual.
*   **[Script Hardening](./REFERENCE/Script-Hardening-Best-Practices-Ref.md)**: Security, error handling, and strict mode.
*   **[POSIX vs. Bash](./REFERENCE/POSIX-vs-Bash-Compatibility-Ref.md)**: Portability and compatibility standards.
*   **[Regular Expressions](./REFERENCE/Regular-Expressions-Ref.md)**: RegEx for shell tools and validation.

---

## 🎯 The Automation Why: Shell as Infrastructure Foundation

**For Beginners**: Before you write Terraform configs or Kubernetes YAML, you need to understand Shell. Here's why:

### The Cloud Bootstrap Reality
When you click "Launch Instance" in AWS, the very first code that runs on that server is a **Shell script** (called "User Data"). Even though AWS has fancy GUIs and APIs, at the OS level, it's all Shell commands installing packages, configuring services, and setting up monitoring.

### The CI/CD Pipeline Truth
Every Jenkins job, GitHub Action, or GitLab pipeline ultimately runs Shell commands:
```yaml
# This GitHub Action YAML...
- name: Deploy to production
  run: |
    ./scripts/build.sh
    ./scripts/test.sh
    ./scripts/deploy.sh
```
...is just **organized Shell scripting** with a pretty interface.

### The Glue Between Tools
- **Terraform** calls Shell hooks (provisioners)
- **Ansible** executes Shell commands on remote servers
- **Docker** builds run Shell in containers
- **Kubernetes** init containers run Shell setup scripts

**Bottom Line**: You can't escape Shell in DevOps. Master it early, or struggle later.

---

## 🎨 Visual Learning: Architecture Diagrams

Throughout this curriculum, you'll find SVG diagrams explaining complex concepts:

- **`./assets/shell_architecture.svg`** → How commands flow from user to hardware
- **`./assets/pipeline_architecture.svg`** → Stream processing (stdin/stdout/stderr)
- **`./assets/permission_architecture.svg`** → Security and access control
- **`./assets/function_architecture.svg`** → Modular script design

**Pro Tip**: Open these in a browser while reading to visualize the mental model.

---

## 🛠️ Getting Started

### Running Scripts
To run any script in this repo:
```bash
chmod +x script.sh  # Make executable (one-time)
./script.sh         # Execute in current directory
```

### Essential Developer Tools

**🔍 ShellCheck: Your New Best Friend**
```bash
# Install ShellCheck (syntax/best practice linter)
# Ubuntu/Debian:
sudo apt install shellcheck

# macOS:
brew install shellcheck

# Check your scripts BEFORE running them:
shellcheck deploy.sh
```

**Why ShellCheck Matters**: A single unquoted variable can delete your entire production database. ShellCheck catches these disasters before they happen. **Use it on every script.**

**Example of What ShellCheck Catches**:
```bash
# ❌ DISASTER WAITING TO HAPPEN
backup_dir=""
rm -rf $backup_dir/*  # Expands to: rm -rf /*

# ShellCheck warns:
# Line 2: Double quote to prevent globbing and word splitting
```

---

## 📊 The Learning Path: Beginner's Map

```
Week 1-2: Part 1 (Foundations)
├─ Can navigate filesystem blindfolded
├─ Can create/edit files with Vim over SSH
└─ Understand permission models (chmod/chown)

Week 3-4: Part 2 (Architecture)  
├─ Write conditional logic (if/else)
├─ Automate repetitive tasks with loops
└─ Build reusable functions

Week 5-6: Part 3 (System Drafting)
├─ Build production-ready scripts
├─ Master I/O redirection and pipes
└─ Integrate Shell into CI/CD workflows
```

---

## 🎯 Mission-Based Learning Philosophy

Unlike traditional tutorials with "Hello World" examples, every code sample in this curriculum is based on **real DevOps tasks**:

- Instead of `echo "Hello"` → **Check if critical services are running**
- Instead of `for i in {1..10}` → **Backup all databases in a list**
- Instead of `if [ $a -eq 1 ]` → **Deploy only if health checks pass**

**Why**: You'll build muscle memory for actual infrastructure automation, not toy problems.

---

Remember: **Shell is about composability.** Small tools combined to do big things.
