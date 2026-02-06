# 🧩 Regular Expressions for Shell Tools
*Version 1.0 | Mastering the Pattern Matching Grammar*

---

## 📖 Overview
Regular Expressions (RegEx) are a sequence of characters that define a search pattern. In shell scripting and CLI tools, RegEx is the primary way to perform massive search, filter, and replace operations across logs and configuration files.

---

## 🏗️ Technical Pillars: RegEx Flavors

### 1. BRE (Basic Regular Expressions)
- **Used by**: Standard `grep`, `sed`.
- **Note**: Most meta-characters like `+`, `?`, `|`, `(`, `)` must be escaped with a backslash to be treated as special.
- **Example**: `grep 'a\{2,3\}' file.txt` (Matches 2-3 'a's).

### 2. ERE (Extended Regular Expressions)
- **Used by**: `grep -E` (or `egrep`), `awk`.
- **Note**: No backslashes needed for meta-characters.
- **Example**: `grep -E 'a{2,3}' file.txt`.

### 3. PCRE (Perl Compatible Regular Expressions)
- **Used by**: `grep -P`.
- **Note**: The most powerful flavor. Supports lookaheads, lookbehinds, and non-greedy matching.

---

## ⚙️ Core Meta-Characters

| Char | Meaning | Example |
| :--- | :--- | :--- |
| `.` | Any single character | `h.t` matches `hat`, `hot`. |
| `*` | Zero or more of the previous | `a*` matches ``, `a`, `aa`. |
| `^` | Start of line | `^Root` matches lines starting with Root. |
| `$` | End of line | `!$` matches lines ending with !. |
| `[ ]`| Character set | `[aeiou]` matches any vowel. |
| `|` | OR (ERE/PCRE) | `cat|dog` matches cat or dog. |
| `\d` | Any digit (PCRE) | `\d+` matches 123. |
| `\b` | Word boundary | `\bcat\b` matches `cat` but not `scatter`. |

---

## 🚀 SRE Use Case: Log Validation
```bash
# Verify if a log line starts with a valid ISO 8601 Date
# Example line: 2023-10-25T14:00:00Z ERROR Database full
grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}T' production.log
```

---

## 🛡️ SRE Standard Checklist
- [ ] **Escaping**: Always wrap your RegEx in single quotes (`' '`) to prevent the shell from expanding characters like `*` or `$`.
- [ ] **Greediness**: Be aware that `.*` is "greedy" and will match as much as possible. Use non-greedy `.*?` in PCRE for more control.
- [ ] **Tool Version**: Know if you are using GNU `grep` (common on Linux) or BSD `grep` (common on macOS), as flags and RegEx support vary.

---

## ❓ Interview "Deep-Cut" Questions
1. **What is the difference between `.*` and `.+` in Extended Regular wood?**
2. **How do you escape a literal dot (`.`) in a RegEx to ensure it doesn't match "any character"?**
3. **What is a "Non-Capturing Group" (`(?:...)`) and why is it useful for performance?**
4. **Explain "Assertion" in RegEx (e.g., `^` and `$`). Do they consume characters?**
5. **Describe how you would use a "Negative Lookahead" to find lines that contain "ERROR" but NOT "Timeout".**

---
**Back to foundations**: [Shell Fundamentals →](./Shell-Fundamentals-Ref.md)
