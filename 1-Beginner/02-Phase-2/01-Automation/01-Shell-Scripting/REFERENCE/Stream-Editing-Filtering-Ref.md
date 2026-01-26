# 🧶 Stream Editing & Filtering Mastery
*Version 1.0 | The Power Trinity: Grep, Sed, and Awk*

---

## 📖 Overview
Dynamic infrastructure generates massive logs and configuration data. Mastering the core text-processing tools—`grep` (Search), `sed` (Modify), and `awk` (Format)—is vital for extracting actionable intelligence from unstructured data.

---

## 🔍 Grep (Global Regular Expression Print)
**Purpose**: Searching for patterns in files or standard input.
- `-i`: Case-insensitive search.
- `-v`: Invert match (show lines that **do not** match).
- `-r`: Recursive search in directories.
- `-E`: Enable Extended RegEx (ERE).
- `-o`: Only show the matching part, not the whole line.

---

## ✂️ Sed (Stream Editor)
**Purpose**: Non-interactive editing of text streams.
- **Substitution Syntax**: `sed 's/old/new/g' file.txt`
- **In-place Edit**: `sed -i 's/prod/stage/g' config.yml` (Dangerous!)
- **Delete Lines**: `sed '5d' file.txt` (Deletes line 5).
- **Insert/Append**: `i` (Insert before), `a` (Append after).

---

## 📊 Awk (The Text Processing Language)
**Purpose**: Data extraction and field manipulation. Awk views files as rows and columns.
- **Default Delimiter**: Whitespace.
- **Syntax**: `awk 'pattern { action }' file`
- **Common Columns**:
  - `$0`: Full line.
  - `$1`, `$2`: First and second columns.
  - `NF`: Number of Fields (Columns).
  - `NR`: Number of Records (Line Number).

### 🚀 SRE Use Case: Log Summary
```bash
# Extract IPs from an access log and count unique occurrences
cat access.log | awk '{print $1}' | sort | uniq -c | sort -nr
```

---

## 🏛️ Comparison Matrix

| Tool | Focus | Primary Strength |
| :--- | :--- | :--- |
| **Grep** | Lines | Blazing fast pattern matching. |
| **Sed** | Characters | Efficient find-and-replace transformations. |
| **Awk** | Fields | Mathematical operations and structured reporting. |

---

## 🛡️ SRE Standard Checklist
- [ ] **Pipe Safety**: Avoid long pipelines (`cat | grep | awk | sed`); try combining logic into a single `awk` command for efficiency.
- [ ] **Line-Ending Protection**: Be aware of Windows (`\r\n`) vs Linux (`\n`) line endings when parsing files.
- [ ] **Escaping**: Always handle special characters (`/`, `.`, `$`) carefully within shell strings.

---

## ❓ Interview "Deep-Cut" Questions
1. **Explain the difference between `sed 's/a/b/'` and `sed 's/a/b/g'`.**
2. **How does `awk` handle a custom delimiter like a comma (CSV) via CLI?**
3. **What is the difference between BRE (Basic) and ERE (Extended) regular expressions in terms of meta-character handling?**
4. **When would you use `pcregrep` instead of standard `grep`?**
5. **Describe how to extract the 3rd to last column of a space-separated file using `awk`.**

---
**Next Step**: [Script Hardening & Best Practices →](./Script-Hardening-Best-Practices-Ref.md)
