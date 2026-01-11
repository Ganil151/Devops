# 📜 Finally Scripting (From CLI to File)

> **"If you have to type it twice, script it once."**

![Scripting Banner](../../assets/scripting_banner.png)

## 📚 Overview

You've learned navigation, file manipulation, and permissions. Now we bring it all together. A **Shell Script** is simply a text file containing the same commands you type in the terminal, executed sequentially. This is the heart of automation.

## 🎓 Learning Objectives

By the end of this module, you will:

- ✅ Create your first proper `.sh` script
- ✅ Understand the **Shebang** (`#!`) and why it's mandatory
- ✅ Master the "Write, Chmod, Run" cycle
- ✅ Use comments effectively for documentation
- ✅ Debug scripts using `bash -x`

## 🏗️ The Script Anatomy

Every robust script has three main components:

```mermaid
graph TD
    A[Shebang #!/bin/bash] --> B[Metadata / Comments]
    B --> C[The Payload (Commands)]
    
    style A fill:#e74c3c,color:#fff
    style B fill:#f1c40f,stroke:#333
    style C fill:#2ecc71,color:#fff
```

### 1. The Shebang (`#!`)
The very first line tells the kernel which **interpreter** to use.
- `#!/bin/bash` -> Use Bash (Standard)
- `#!/bin/sh` -> Use SH (Strict POSIX)
- `#!/usr/bin/env python3` -> Use Python (Yes, shebangs work for any language!)

### 2. The Code
```bash
#!/bin/bash

# Define variables
PROJECT="DeathStar"
DATE=$(date +%F)

echo "Starting construction on $PROJECT at $DATE..."
mkdir -p "$PROJECT"
cd "$PROJECT"
touch "reactor_plans.txt"

echo "✅ Construction complete."
```

## 🛠️ The Execution Cycle

1.  **Create**: `vim deploy.sh`
2.  **Make Executable**: `chmod +x deploy.sh`
3.  **Run**: `./deploy.sh`

**Note**: You must use `./` (current directory) because the current directory is intentionally NOT in your `$PATH` for security specific reasons.

## 🐛 Debugging Mode

Scripts failing silently? Bash has a built-in tracer.

```bash
# Run with debug trace enabled
bash -x deploy.sh
```

**Output:**
```
+ PROJECT=DeathStar
++ date +%F
+ DATE=2026-01-10
+ echo 'Starting construction...'
Starting construction...
```
You see every variable expansion and command before it runs!

## 🏆 Real-World DevOps Story

### 💡 **The Cron Job Mystery**

**Scenario**: A script `backup.sh` worked perfectly when the admin ran it manually, but failed every night when run by Cron (scheduler).

**The Bug**:
The script started with:
```bash
cd documents
tar -czf backup.tar.gz .
```

**The Cause**:
When run manually, the admin was in `/home/admin`.
When run by Cron, the default directory is `/home/admin` (sometimes) or `/root`.
Also, Cron has a **limited PATH**. It couldn't find `tar`.

**The Fix**:
1. Added full Shebang `#!/bin/bash`
2. Used absolute paths: `cd /home/admin/documents`
3. Defined PATH explicitly at the top of the script.

**Lesson**: Scripts must be **independent** of the user's current environment.

## 🎓 Interview Questions

### Q1: What is the difference between `#!/bin/bash` and `#!/usr/bin/env bash`?
<details>
<summary>Click to reveal answer</summary>

- `#!/bin/bash`: Hardcoded path. Fails if bash is installed in `/usr/local/bin` (common on BSD/macOS).
- `#!/usr/bin/env bash`: Searches the user's `$PATH` to find the first instance of `bash`. More portable across different OSs.
</details>

### Q2: How do you run a script that is NOT executable?
<details>
<summary>Click to reveal answer</summary>

Pass it as an argument to the interpreter:
```bash
bash script.sh
```
This overrides the permission check and ignores the shebang line.
</details>

### Q3: What is "Exit Code"?
<details>
<summary>Click to reveal answer</summary>

Every command returns a number (0-255) to the OS upon finishing.
- `0`: Success
- `1-255`: Error
You can access it via `$?` immediately after the command runs.
</details>

## 📝 Quiz

1. **What must be the very first characters of a script?**
   - [ ] a) `//`
   - [ ] b) `<?`
   - [x] c) `#!`
   - [ ] d) `>>`

2. **Which command makes a script runnable?**
   - [ ] a) `run script.sh`
   - [x] b) `chmod +x script.sh`
   - [ ] c) `chown +x script.sh`
   - [ ] d) `make script.sh`

3. **Why do we use `./script.sh` instead of just `script.sh`?**
   - [ ] a) Because it's safer
   - [ ] b) Because current directory is rarely in PATH
   - [ ] c) Because it specifies the path explicitly
   - [x] d) All of the above

4. **Which flag enables debugging mode in bash?**
   - [ ] a) `-d`
   - [x] b) `-x`
   - [ ] c) `-v`
   - [ ] d) `-g`

5. **What variable stores the exit code of the last command?**
   - [ ] a) `$EXIT`
   - [ ] b) `$#`
   - [x] c) `$?`
   - [ ] d) `$$`

**Answers**: 1-c, 2-b, 3-d, 4-b, 5-c

## 🔗 Next Steps

Continue to: **[User Input](../13-User-Input/README.md)** →

## 📚 Additional Resources
- [ShellCheck](https://www.shellcheck.net/) - Paste your script here to find bugs instantly.
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)

---
**📌 Pro Tip**: Configure your editor to auto-insert the shebang 
`#!/bin/bash` whenever you create a file ending in `.sh`!
