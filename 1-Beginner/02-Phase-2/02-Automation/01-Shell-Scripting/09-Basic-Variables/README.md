# 📦 Basic Variables (Storing Data)

> **"Hardcoding is the root of all evil. Abstraction is the path to salvation."**

![Variables Banner](../../assets/variables_banner.png)

## 📚 Overview

Variables allow you to store data, manage configuration, and make your scripts dynamic. Instead of hardcoding paths like `/var/www/html` everywhere, you define `WEB_ROOT=/var/www/html` once. If the path changes, you update one line.

## 🎓 Learning Objectives

By the end of this module, you will:

- ✅ Define and access variables in Bash
- ✅ Understand the syntax: `VAR=value` (no spaces!)
- ✅ Distinguish between Local Variables and Environment Variables
- ✅ Use best practices: quoting and curly braces `${VAR}`
- ✅ Inherit variables in child scripts using `export`

## 🏗️ The Variable Lifecycle

```mermaid
graph TD
    A[Define: NAME="DevOps"] --> B[Access: echo $NAME]
    B --> C{Exported?}
    
    C -- No --> D[Local Scope Only]
    C -- Yes --> E[Environment Scope]
    
    E --> F[Available to Child Processes]
    D --> G[Invisible to Child Processes]
    
    style A fill:#3498db,color:#fff
    style E fill:#2ecc71,color:#fff
    style D fill:#e74c3c,color:#fff
```

## 🛠️ Essential Syntax

### 1. Assignment
**Rule #1**: NO SPACES around the `=` sign.

```bash
# ✅ Correct
APP_PORT=8080
MESSAGE="Hello World"

# ❌ Wrong
APP_PORT = 8080   # Tries to run command "APP_PORT"
APP_PORT= 8080    # Tries to run "8080" with APP_PORT env
```

### 2. Accessing Values
Use `$` to retrieve value.

```bash
echo $APP_PORT
```

### 3. Best Practice: Curly Braces `${}`
Always use brackets when concatenating.

```bash
FILE="data"
# We want to create "data_backup"

echo "$FILE_backup"   # ❌ Looks for var $FILE_backup (empty)
echo "${FILE}_backup" # ✅ Correct
```

## 🌍 Local vs. Environment Variables

- **Local**: Only exists in the current shell.
- **Environment**: Passed down to programs/scripts you run.

```bash
# Local
my_secret="12345"
./deploy.sh      # deploy.sh CANNOT see my_secret

# Environment
export MY_SECRET="12345"
./deploy.sh      # deploy.sh CAN see MY_SECRET
```

### Scope Visualization
```mermaid
graph TD
    subgraph ParentShell [Parent Shell (PID 100)]
        VAR1[Local: A=1]
        VAR2[Exported: B=2]
        
        Process[Runs ./child.sh]
    end
    
    subgraph ChildShell [Child Shell (PID 101)]
        INHERIT[Inherits: B=2]
        MISSING[Missing: A]
    end
    
    VAR2 --> INHERIT
    VAR1 -.->|X| MISSING
    
    style ParentShell fill:#e8f4f8
    style ChildShell fill:#fef9e7
```

## 🏆 Real-World DevOps Story

### 💡 **The Production Deletion**

**Scenario**: A deployment script had a cleanup section:

```bash
TARGET_DIR=""  # Accidentally left empty
rm -rf "$TARGET_DIR/"*
```

**The Disaster**:
Because `$TARGET_DIR` was empty, the command evaluated to `rm -rf / *`.
It tried to delete the root filesystem.

**The Fix**:
Always check if variables are set before using them ("Defensive Coding").

```bash
: "${TARGET_DIR:?Variable not set or empty}"
rm -rf "${TARGET_DIR}/"*
```

If `TARGET_DIR` is empty, the script crashes immediately with an error message instead of nuking the server.

## 🎓 Interview Questions

### Q1: What is the difference between `$VAR` and `${VAR}`?
<details>
<summary>Click to reveal answer</summary>

Functionally they are the same, but `${VAR}` is safer. It strictly delimits the variable name.
Required when appending text immediately after the variable: `${VAR}_suffix`.
</details>

### Q2: How do you make a variable permanent?
<details>
<summary>Click to reveal answer</summary>

You can't make it truly permanent in memory. You must add the definition to your shell startup file (`~/.bashrc` or `~/.zshrc`).
```bash
echo 'export JAVA_HOME="/usr/lib/java"' >> ~/.bashrc
```
</details>

### Q3: What usually denotes a constant variable in shell scripting?
<details>
<summary>Click to reveal answer</summary>

By convention, environment variables and constants are `UPPERCASE` (e.g., `HOME`, `PATH`), while local variables are `lowercase`. This isn't enforced by text, but is a strong community standard.
</details>

## 📝 Quiz

1. **Which assignment is valid?**
   - [ ] a) `NAME = "John"`
   - [x] b) `NAME="John"`
   - [ ] c) `NAME-="John"`
   - [ ] d) `$NAME="John"`

2. **How do you make a variable available to child scripts?**
   - [ ] a) `share VAR`
   - [ ] b) `global VAR`
   - [x] c) `export VAR`
   - [ ] d) `public VAR`

3. **What prints the value of `USER`?**
   - [ ] a) `echo USER`
   - [x] b) `echo $USER`
   - [ ] c) `print USER`
   - [ ] d) `cat USER`

4. **If `fruit="apple"`, what does `echo "${fruit}pie"` print?**
   - [x] a) `applepie`
   - [ ] b) `fruitpie`
   - [ ] c) `apple`
   - [ ] d) Error

5. **Where should you define persistent environment variables?**
   - [ ] a) terminal
   - [ ] b) `.history`
   - [x] c) `.bashrc`
   - [ ] d) `/tmp`

**Answers**: 1-b, 2-c, 3-b, 4-a, 5-c

## 🔗 Next Steps

Continue to: **[Vim Crash Course](../10-Vim-Crash-Course/README.md)** →

## 📚 Additional Resources
- [Bash Guide on Variables](https://mywiki.wooledge.org/BashGuide/Parameters)
- [Shell Style Guide: Naming Conventions](https://google.github.io/styleguide/shellguide.html#s7-naming-conventions)

---
**📌 Pro Tip**: Use `env` to list all current environment variables and `set` to list all variables (including local ones).
