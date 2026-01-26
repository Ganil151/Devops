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

## 🛠️ Getting Started

To run any script in this repo:
```bash
chmod +x script.sh
./script.sh
```

Remember: **Shell is about composability.** Small tools combined to do big things.
