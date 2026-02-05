# 🔍 Regex & Data Parsing: The Language of Patterns

> **"Regex is a write-only language. If you don't document your pattern, even you won't understand it tomorrow."**

Welcome to the **Regex Mastery** module. Regular Expressions (Regex) are the universal language for string matching. Whether you are using Python, grep, Sed, VSCode Search, or checking an email address in JavaScript—Regex is the engine under the hood.

**Why This Matters for Junior DevOps Engineers:**
- 🛡️ **Security**: "Validate this input is an IP address" requires Regex.
- ⚡ **Debugging**: "Find all 500 errors in this 2GB log" requires `grep` with Regex.
- 🎯 **Interview**: "Write a pattern to match a valid email address."
- 🔧 **Cleanup**: "Find and delete all Docker images that look like `test-v1.x`."

---

## 📚 Table of Contents

1. [Regex Architecture (BRE vs ERE vs PCRE)](#-regex-architecture-bre-vs-ere-vs-pcre)
2. [The Building Blocks](#-the-building-blocks)
3. [Anchors & Boundaries](#-anchors--boundaries)
4. [Groups & Backreferences](#-groups--backreferences)
5. [Real-World DevOps Scenarios](#-real-world-devops-scenarios)
6. [Security Best Practices](#-security-best-practices)
7. [Common Pitfalls & Solutions](#-common-pitfalls--solutions)
8. [Hands-On Exercises](#-hands-on-exercises)
9. [Interview Preparation](#-interview-preparation)
10. [Knowledge Check](#-knowledge-check)

---

## 🏗️ Regex Architecture: BRE vs ERE vs PCRE

Not all regex engines are the same. This causes 90% of confusion.

| Engine | Command | Capabilities | Use Case |
|:---|:---|:---|:---|
| **BRE** (Basic) | `grep`, `sed` | Limited. Need to escape `\+`, `\?`, `\|`. | Legacy scripts. |
| **ERE** (Extended) | `grep -E`, `sed -E` | Standard. `+`, `?`, `\|` work natively. | **Standard DevOps use**. |
| **PCRE** (Perl) | `grep -P` | Advanced. Lookaheads `(?=...)`, `\d`, `\w`. | Complex validation. |

**Rule of Thumb**: Always use **ERE** (`-E`) for portability and sanity.

---

## 🧱 The Building Blocks

### 1. Character Classes `[ ]`
Match ONE character from a set.
- `[abc]`: Matches "a", "b", or "c".
- `[a-z]`: Matches any lowercase letter.
- `[0-9]`: Matches any digit.
- `[^0-9]`: Matches anything that is **NOT** a digit (Negation).

### 2. Quantifiers `* + ? {}`
How many times should the previous character appear?
- `*`: 0 or more (Greedy). `a*` matches "", "a", "aaaa".
- `+`: 1 or more. `a+` matches "a", "aaaa". (ERE only)
- `?`: 0 or 1. `a?` matches "" or "a". (Optional).
- `{3}`: Exactly 3 times. `[0-9]{3}` matches "123".

### 3. The Dot `.`
Matches **ANY** single character (except newline).

---

## ⚓ Anchors & Boundaries

These don't consume characters; they match **Positions**.

### 1. Line Anchors
- `^Start`: Matches if "Start" is at the **beginning** of lines.
- `End$`: Matches if "End" is at the **end** of lines.

```bash
# Finds lines starting with '#', but NOT " # comment"
grep "^#" config.file
```

### 2. Word Boundaries `\b`
Matches the gap between a word and a space/punctuation.
- `\broot\b`: Matches "root" but **not** "reboot" or "roots".

---

## 🔗 Groups & Backreferences

### capture Groups `( )`
Groups characters together.
- `(admin|root)`: Matches "admin" OR "root".

### Backreferences `\1`
Refers to what was matched in the 1st Group. `sed` uses this for swapping.

```bash
# Swap First Last -> Last, First
echo "John Doe" | sed -E 's/([A-Za-z]+) ([A-Za-z]+)/\2, \1/'
# Output: Doe, John
```

---

## 🎭 Real-World DevOps Scenarios

### 🛡️ Scenario 1: The IP Address Validator
**Task**: Find all valid IPv4 addresses in a chaotic log file.
**Pattern**:
```bash
grep -E -o "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" server.log
```
**Explanation**:
- `\b`: Word boundary start.
- `([0-9]{1,3}\.){3}`: Matches "192." three times.
- `[0-9]{1,3}`: Matches "100" (last octet).
- `\b`: Word boundary end.

### 🔥 Scenario 2: The SemVer Cleanup
**Task**: Find Docker tags matching major version 1 (e.g., `v1.2.3`).
**Pattern**:
```bash
docker images | grep -E "v1\.[0-9]+\.[0-9]+"
```

### ☁️ Scenario 3: Extracting Emails
**Task**: Scrape all email addresses from a leaked CSV.
**Pattern**:
```bash
grep -E -o "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" data.csv
```

---

## 🔒 Security Best Practices

### 1. ReDoS (Regex Denial of Service)
**The Risk**: Nested quantifiers `(a+)+` can cause exponential backtracking if the input doesn't match effectively (O(2^n)).
**Attack**: An attacker sends a malicious 1KB string that freezes your CPU at 100% for hours.
**Fix**: Avoid nested groups with `+` or `*`. Use strict timeouts on Regex execution.

### 2. Anchor Your Validation
**Bad**: `match(/admin/)` -> Matches "bad-admin".
**Good**: `match(/^admin$/)` -> Matches ONLY "admin".

---

## ⚠️ Common Pitfalls

### Pitfall 1: Greediness
Regex is **Greedy** by default. It matches as much as possible.
**Text**: `<tag>Content</tag>`
**Regex**: `<.*>`
**Match**: `<tag>Content</tag>` (The whole thing!)
**Fix**: Use `[^>]*` (Negated class) instead of `.*`.

### Pitfall 2: Escaping Hell
Matching a literal `.` or `*` requires escaping `\.` or `\*`.
**Example**: To match "domain.com", regex is `domain\.com`. If you forget, it matches "domainXcom".

---

## 🎯 Hands-On Exercises

### Exercise 1: The UUID Hunter
**Objective**: Extract UUIDs.
**Format**: 8-4-4-4-12 hex chars (e.g., `123e4567-e89b-12d3-a456-426614174000`).
**Task**: Write a `grep -E` pattern to find them.

### Exercise 2: The Date Standardizer
**Objective**: Convert dates.
**Input**: `12/31/2023` (US Format)
**Task**: Use `sed` to convert to `2023-12-31` (ISO Format).

---

## 🎙️ Interview Preparation

### Foundation Questions

**1. "What does `.*` mean?"**
- **Answer**: It matches **Anything** (except newline), zero or more times. It's the "wildcard" of regex.

**2. "How matches a literal dollar sign `$`?"**
- **Answer**: `\$` or `[$]`.

### Advanced Scenario Questions

**3. "Write a regex to match a password that has at least 1 uppercase, 1 number, and is 8 chars long."**
- **Answer**: Use Lookaheads (PCRE): `(?=.*[A-Z])(?=.*[0-9]).{8,}`.
- Note: This is hard in standard `grep` (needs pipes).

---

## 🧠 Knowledge Check

**1. Which command uses Extended Regex?**
- [ ] `grep`
- [x] `grep -E` (or `egrep`)
- [ ] `grep -F`

**2. What matches 'Start of Line'?**
- [x] `^`
- [ ] `$`
- [ ] `\A`

**3. What does `[0-9]{3}` match?**
- [ ] "0123"
- [x] "123" (Exactly 3 digits)
- [ ] "abc"

---

## 🎓 Self-Assessment Checklist

Before moving to the next module, ensure you can:
- [ ] Explain the difference between `*`, `+`, and `?`.
- [ ] Write a regex for an IP address.
- [ ] Use Capture Groups `( )` in `sed`.
- [ ] Avoid ReDoS vulnerabilities.

**Score yourself**: 5+/5 = Ready to advance | <5 = Review exercises

[⬅️ Back to Data Processing](../README.md) | [Next: Assessments](README.md) ➡️
