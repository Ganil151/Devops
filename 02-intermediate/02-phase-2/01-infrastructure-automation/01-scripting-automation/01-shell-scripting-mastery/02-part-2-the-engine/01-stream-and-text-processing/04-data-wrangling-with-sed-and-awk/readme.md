# ✂️ Data Wrangling: Sed & Awk Mastery

> **"Sed is your Surgeon. Awk is your Accountant. Together, they can restructure any text file on the planet without ever opening an editor."**

Welcome to the **Text Stream Processing** module. Before JSON took over the world, everything was flat text: CSVs, Logs, `/etc/passwd`. `sed` (Stream Editor) and `awk` are the tools built into the Linux kernel's user-space to manipulate this data efficiently.

**Why This Matters for Junior DevOps Engineers:**
- ⚡ **Performance**: `awk` can sum a column in a 10GB CSV file in seconds using <5MB RAM.
- 🔧 **Legacy Systems**: You will encounter systems without Python or JQ. You will *always* have Sed/Awk.
- 🎯 **Interview**: "How do you replace a string in a file without opening it?" (Sed)
- 📊 **Troubleshooting**: "Sum the request size of all 500 errors in this Apache log." (Awk)

---

## 📚 Table of Contents

1. [Sed: The Stream Editor](#-sed-the-stream-editor)
2. [Awk: The Field Processor](#-awk-the-field-processor)
3. [Advanced Patterns (Regex & Math)](#-advanced-patterns-regex--math)
4. [Real-World DevOps Scenarios](#-real-world-devops-scenarios)
5. [In-Place Editing Safety](#-in-place-editing-safety)
6. [Common Pitfalls & Solutions](#-common-pitfalls--solutions)
7. [Hands-On Exercises](#-hands-on-exercises)
8. [Interview Preparation](#-interview-preparation)
9. [Knowledge Check](#-knowledge-check)

---

## ✂️ Sed: The Stream Editor

Sed processes text line-by-line. Its primary use in DevOps is **Substitution**.

### 1. Basic Substitution (`s///`)
Syntax: `s/FIND/REPLACE/FLAGS`

```bash
echo "Hello World" | sed 's/World/DevOps/'
# Output: Hello DevOps
```

### 2. Global Replacement (`g`)
By default, Sed only replaces the *first* match per line. Use `g` for all.

```bash
echo "user: user_1, group: user_group" | sed 's/user/admin/g'
# Output: admin: admin_1, group: admin_group
```

### 3. Changing Delimiters
If you are editing paths (which have `/`), using `/` as a delimiter is painful (`\/path\/to`). Use `#` instead!

```bash
# ❌ Messy
sed 's/\/var\/www\/html/\/var\/www\/new/' config.conf

# ✅ Clean
sed 's#/var/www/html#/var/www/new#' config.conf
```

### 4. Deletion (`d`)
Remove lines processing specific patterns.

```bash
# Delete all lines containing "password"
sed '/password/d' config.ini

# Delete empty lines
sed '/^$/d' file.txt
```

---

## 📊 Awk: The Field Processor

Awk sees every line as a collection of **Rows** and **Columns** (Fields).
- `$0`: The entire line.
- `$1`: The first column.
- `$NF`: The last column.

### 1. Basic Printing
```bash
# Print User (Col 1) and Shell (Col 7) from /etc/passwd
# Delimiter: Colon (:)
awk -F: '{print "User: " $1 ", Shell: " $7}' /etc/passwd
```

### 2. Filtering Rows
Awk works like `grep` + specific logic.

```bash
# Print lines where Column 3 (User ID) is greater than 1000
awk -F: '$3 >= 1000 {print $1}' /etc/passwd
```

### 3. The `BEGIN` and `END` Blocks
Powerful for aggregation.
1. `BEGIN`: Run once before processing lines.
2. Main Block`: Run for every line.
3. `END`: Run once after all lines.

```bash
# Calculate average response time (Col 4) from a log
awk '{sum += $4; count++} END {print "Average Time:", sum/count}' access.log
```

---

## 🧠 Advanced Patterns (Regex & Math)

### Sed Capture Groups `( )`
Reuse parts of the match. escaped parentheses `\(` are required in standard sed (or use `sed -E` for modern regex).

```bash
# Convert "KEY=VALUE" to "VALUE: KEY"
echo "status=active" | sed -E 's/([a-z]+)=([a-z]+)/\2: \1/'
# Output: active: status
```

### Awk Formatting (`printf`)
Standard `print` is messy with floats. Use `printf` for C-style formatting.

```bash
awk '{printf "User: %-10s ID: %04d\n", $1, $3}' users.txt
# Output:
# User: gsmash     ID: 1001
# User: admin      ID: 0001
```

---

## 🎭 Real-World DevOps Scenarios

### 🛡️ Scenario 1: The SSH Hardening Script (Sed)
**Task**: Disable Root Login in `sshd_config`.
**Logic**: Find `PermitRootLogin yes` (or commented out `PermitRootLogin`) and force it to `no`.

```bash
# -i = in-place edit
# -E = Extended Regex
sed -i.bak -E 's/^#?PermitRootLogin (yes|prohibit-password)/PermitRootLogin no/' /etc/ssh/sshd_config
```

### 🔥 Scenario 2: Apache Log 500 Error Analysis (Awk)
**Task**: Find the Top 3 IP addresses causing 500 Errors.
**Log Format**: `IP - - [Date] "GET /path" STATUS SIZE`

```bash
# Pipeline Strategy:
# 1. Filter code 500 (Column 9)
# 2. Extract IP (Column 1)
# 3. Sort & Count
awk '$9 == 500 {print $1}' access.log | sort | uniq -c | sort -rn | head -n 3
```

### ☁️ Scenario 3: Docker Image Cleanup (Awk)
**Task**: Delete all Docker images labeled `<none>`.

```bash
docker images | awk '$1 == "<none>" {print $3}' | xargs -r docker rmi
```

---

## ⚠️ In-Place Editing Safety (`sed -i`)

`sed -i` is destructive. It overwrites the file.

**Best Practice**: Always use a backup extension.
```bash
sed -i.bak 's/foo/bar/' prod.conf
```
This creates `prod.conf` (new) and `prod.conf.bak` (original). If you mess up, `mv prod.conf.bak prod.conf`.

---

## ⚠️ Common Pitfalls

### Pitfall 1: Mac vs Linux Sed
MacOS uses BSD `sed`, Linux uses GNU `sed`.
- Linux: `sed -i 's/a/b/' file`
- MacOS: `sed -i '' 's/a/b/' file` (Requires empty string for backup extension)
**Fix**: Install `gnu-sed` on Mac or avoid `-i` in shared scripts (use temp files).

### Pitfall 2: Shell Variables in Awk
Awk doesn't see Bash variables directly.
**Bad**: `awk '/$VAR/ {print}' file`
**Good**: `awk -v Search="$VAR" '$0 ~ Search {print}' file`

---

## 🎯 Hands-On Exercises

### Exercise 1: The Config Patcher
**Objective**: Update a config file safe.
**Input**: `database.host = localhost`
**Task**: Change `localhost` to `10.0.0.5` using `sed` and creating a `.bak` file.

### Exercise 2: The CSV Sum
**Objective**: Calculate total cost.
**Input** (`expenses.csv`):
```csv
Item,Cost
Server,50
Domain,10
```
**Task**: Use `awk` to sum the 2nd column (ignoring the header).

---

## 🎙️ Interview Preparation

### Foundation Questions

**1. "What is the difference between `sed` and `awk`?"**
- **Answer**: `sed` is best for simple regex finds/replaces across lines. `awk` is best for columnar data analysis and arithmetic.

**2. "How do you print the last column of a file in `awk`?"**
- **Answer**: `{print $NF}`.

### Advanced Scenario Questions

**3. "How do you replace 'http' with 'https' ONLY in lines matching 'prod'?"**
- **Answer**: `sed '/prod/s/http/https/' config.txt`. The `/prod/` serves as an address filter.

---

## 🧠 Knowledge Check

**1. Which flag enables Extended Regex in Sed?**
- [ ] `-r` (Old GNU)
- [x] `-E` (Portable)
- [ ] `-x`

**2. In Awk, what variable holds the Line Number?**
- [ ] `$LINENO`
- [x] `NR` (Number of Records)
- [ ] `LN`

**3. How do you delete the first 5 lines of a file with Sed?**
- [ ] `sed -rm 5`
- [x] `sed '1,5d'`
- [ ] `sed 'd5'`

---

## 🎓 Self-Assessment Checklist

Before moving to the next module, ensure you can:
- [ ] Replace text using `sed 's/find/replace/g'`.
- [ ] Use a custom delimiter (e.g., `#`) for paths.
- [ ] Print specific columns with `awk '{print $1}'`.
- [ ] Filter rows with `awk '$3 > 50'`.
- [ ] Calculate a sum of a column.

**Score yourself**: 5+/5 = Ready to advance | <5 = Review exercises

[⬅️ Back to Data Processing](../readme.md) | [Next: Advanced Patterns](readme.md) ➡️
