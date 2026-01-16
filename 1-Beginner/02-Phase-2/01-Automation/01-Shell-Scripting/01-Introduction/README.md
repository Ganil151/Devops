# 🎯 Introduction to Shell Scripting
>
> **"The shell is the command interpreter in Linux. It is the interface between the user and the operating system."**
![Shell Scripting Architecture](./shell_architecture.svg)

## 📚 Overview

Shell scripting is the foundation of automation in DevOps. A **shell script** is a text file containing a series of commands that are executed by the shell interpreter. Think of it as a recipe where each command is a step toward achieving a specific automation goal. For a DevOps professional, shell scripting is the "glue" that binds different tools, clouds, and services together.

## 🎓 Learning Objectives

By the end of this module, you will:

- ✅ Understand what shell scripting is and why it's crucial for DevOps.
- ✅ Learn about different shell types (**Bash, Zsh, Sh**).
- ✅ Recognize when to use shell scripts vs. Python or Go.
- ✅ Write and execute your first "Hello World" automation.
- ✅ Understand the **Shebang** (`#!/bin/bash`) mechanic.

---

## 🏗️ The Trio of Popular Shells

While there are dozens of shells, these three dominate the industry.

| Shell | Description | Use Case |
|-------|-------------|----------|
| **Bash** | Bourne Again Shell | The standard for Linux distributions and CI/CD pipelines. |
| **Sh** | Original Bourne Shell| Used for legacy systems and strict POSIX compliance. |
| **Zsh** | Z Shell | The modern default for macOS and developer-friendly environments. |

---

## 🚀 Why Shell Scripting?

### 1. Automation

- Automated server deployments.
- Daily database backups.
- Log rotation and cleanup.

### 2. Infrastructure Management

- Server provisioning (Cloud-init).
- Configuration management.
- Health checks and system monitoring.

---

## 🛠️ Your First Script: Hello Automation

### 1. Create the File

```bash
touch hello.sh
```

### 2. Add the Code

```bash
#!/bin/bash
# This is a comment
echo "Hello, DevOps World! 🚀"
```

### 3. Execution (The Two Ways)

- **Method A**: `bash hello.sh` (Runs the script through the bash binary).
- **Method B**: `./hello.sh` (Requires `chmod +x` first).

---

## 📑 The Introduction Cheat Sheet

| Concept | Definition |
|---------|------------|
| **Shell** | The interpreter that reads your commands. |
| **Terminal** | The window where you interact with the shell. |
| **Shebang** | `#!` - Tells the Kernel which interpreter to use. |
| **Script** | A sequence of commands saved in a file. |
| **POSIX** | A set of standards ensuring script portability. |

---

## 🏆 Real-World DevOps Story

### 💡 **The Manual Laborer**

**The Scenario**: An engineer was spent 2 hours every morning manually checking if 50 servers were online by pinging them one by one.
**The Fix**:
They wrote a 5-line shell script that looped through the IP addresses and sent a Slack alert if any server failed. A task that took **120 minutes** was reduced to **0 minutes** of human time
---

## 📝 Knowledge Check

1. **What are the first two characters of a Shebang?**
   - [ ] a) `//`
   - [x] b) `#!`
   - [ ] c) `$`
2. **Which shell is the most popular for Linux automation?**
   - [ ] a) Zsh
   - [x] b) Bash
   - [ ] c) Fish
3. **True or False: Shell scripts must be compiled before they can run.**
   - [ ] a) True
   - [x] b) False
**Answers**: 1-b, 2-b, 3-b

## 🔗 Next Steps

Continue to: **[Terminal and Finder](../02-Terminal-and-Finder/README.md)** →
