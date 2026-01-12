# 💻 Programs and Commands (The DevOps Execution Layer)
> **"Linux is an orchestra of small, specialized programs. Mastering the shell means knowing how to conduct them."**
![Command Resolution Order](./command_resolution_order.svg)
## 📚 Overview
In the Linux ecosystem, a "command" is rarely a single monolithic entity. Modern infrastructure relies on the seamless interaction between **Shell Built-ins** and **External Binaries**. To build reliable automation, a DevOps engineer must understand how the shell identifies these programs, where they live, and how to harness the "Power Toolkit" (`grep`, `sed`, `awk`, `curl`, `jq`) to process data at scale.
## 🎓 Learning Objectives
By the end of this module, you will:
- ✅ Distinguish between **Internal (Built-in)** and **External** execution.
- ✅ Master the **Command Resolution Order** to prevent "Ghost Command" bugs.
- ✅ Understand the core DevOps toolkit: Data filtering, stream editing, and API interaction.
- ✅ Implement defensive `PATH` management in automation scripts.
- ✅ Use `type` and `which` to audit execution sources.
---
## 🏗️ Execution Architecture: Built-ins vs. Externals
### 1. Shell Built-ins (The "Internal" Engine)
Built-ins are commands compiled directly into the shell (Bash, Zsh) binary.
- **Speed**: Extremely fast (no new process is created).
- **Control**: They can modify the shell's own state (e.g., changing directories or setting variables).
- **Identify with**: `type command_name`.
- **Examples**: `cd`, `echo`, `export`, `alias`, `read`, `history`.
### 2. External Programs (The "Disk" Binaries)
These are independent files residing on the filesystem.
- **Speed**: Slower (the shell must `fork()` a new process and `exec()` the binary).
- **Scope**: They cannot change the parent shell's environment variables or current directory.
- **Identify with**: `which command_name`.
- **Examples**: `ls`, `grep`, `docker`, `terraform`, `jq`.
---
## 🛠️ The DevOps Power Toolkit
DevOps automation is essentially the art of **Data Plumbing**. These five tools are the industry standard for processing infrastructure data.
### 1. `grep` (The Filter)
Search for text patterns using Regular Expressions.
- **Usage**: `grep -r "ERROR" /var/log/`
- **Automation Tip**: Use `grep -q` (quiet mode) in `if` statements to check for the existence of a string without printing it.
### 2. `sed` (The Stream Editor)
Transform text on the fly.
- **Usage**: `sed -i 's/localhost/db.production.internal/g' config.yaml`
- **Automation Tip**: Perfect for dynamically updating configuration files during a CI/CD deployment.
### 3. `awk` (The Report Generator)
Powerful field-based text processing.
- **Usage**: `awk '{print $1}' access.log` (Extracts only the IP addresses from a web log).
- **Automation Tip**: Use `awk` when you need to perform math on logs (e.g., summing up file sizes).
### 4. `curl` (The API Requester)
Transfer data to or from a server.
- **Usage**: `curl -X POST -d @payload.json https://api.ops.com/deploy`
- **Automation Tip**: The backbone of interacting with Cloud APIs, Slack hooks, and health endpoints.
### 5. `jq` (The JSON Processor)
The gold standard for handling JSON data in the shell.
- **Usage**: `curl ... | jq '.instances[0].id'`
- **Automation Tip**: Essential for Cloud engineering where every API response is a complex JSON object.
---
## 🚀 Practical Automation Examples
### Example A: The Conditional API Check
Checking if a service is healthy before proceeding with a script.
```bash
# Using curl and grep for status validation
if curl -s --head http://localhost:8080 | grep "200 OK" > /dev/null; then
    echo "✅ Service is UP"
else
    echo "❌ Service is DOWN"
    exit 1
fi
```
### Example B: Dynamic Config Update
Injecting an environment variable into a template.
```bash
# Using sed to replace a placeholder with a variable
DB_HOST="db-01.internal"
sed "s/DB_PLACEHOLDER/$DB_HOST/" template.conf > production.conf
```
---
## 📑 The DevOps Command Cheat Sheet
| Command | Category | DevOps Use Case | Primary Flag |
|---------|----------|-----------------|--------------|
| `type` | Built-in | Check if a command is an alias or binary | `-a` (show all) |
| `which` | External | Find path to an external binary | `-a` (show all) |
| `grep` | External | Filter logs or check config values | `-E` (Extended Regex) |
| `sed` | External | Find-and-replace in files | `-i` (in-place edit) |
| `awk` | External | Column/Field extraction | `-F` (field separator) |
| `jq` | External | Parse Cloud API responses | `-r` (raw output) |
| `curl` | External | Webhooks, API calls, Health checks | `-s` (silent mode) |
| `export`| Built-in | Set environment variables | `-n` (remove export) |
---
## 🏆 Real-World DevOps Story
### 💡 **The Ghost of the Old Version**
**The Scenario**: An SRE updated a custom deployment tool from version 1.0 to 2.0. They placed the new binary in `/usr/local/bin/`. However, the automation scripts were still running version 1.0.
**The Investigation**:
They ran `which deploy-tool` and it pointed to `/usr/local/bin/deploy-tool` (Version 2.0).
They ran `type deploy-tool` and discovered:
`deploy-tool is hashed (/usr/bin/deploy-tool)`
**The Discovery**:
Because the shell had run the old version (located in `/usr/bin/`) earlier in the session, it had **hashed** (cached) the location. Even though the new version was earlier in the `$PATH`, the shell skipped the search and went straight to the cached old version.
**The Fix**:
They ran `hash -d deploy-tool` to clear the cache. For future scripts, they added `hash -r` at the start of upgrade routines to ensure the shell re-scanned the `$PATH`.
---
## 📝 Knowledge Check
1. **Which command identifies if `cd` is a built-in or a binary?**
   - [ ] a) `which cd`
   - [x] b) `type cd`
   - [ ] c) `whereis cd`
2. **Why is `jq` essential for modern DevOps?**
   - [ ] a) It speeds up the shell
   - [x] b) It parses JSON returned by Cloud APIs
   - [ ] c) It replaces the need for `grep`
3. **What happens if you use `sed -i`?**
   - [ ] a) It prints the change to the screen
   - [x] b) It modifies the file directly (In-place)
   - [ ] c) It ignores case sensitivity
**Answers**: 1-b, 2-b, 3-b
## 🔗 Next Steps
Continue to: **[Basic Variables](../09-Basic-Variables/README.md)** →
