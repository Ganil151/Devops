# 🌐 POSIX vs. Bash: Portability Standards
*Version 1.0 | Engineering Cross-Platform Automation Logic*

---

## 📖 Overview
In the SRE world, you might write a script on **CentOS (Bash)** but need it to run on **Alpine Linux (sh/ash)** or **macOS (zsh)**. Understanding the divide between the POSIX standard and Bash extensions is key to technical portability.

---

## 🏗️ The POSIX Standard
**POSIX (Portable Operating System Interface)** defines the baseline behavior that all Unix-like shells should follow.
- **Goal**: Write once, run on any Unix (Linux, BSD, Solaris).
- **Target Shell**: `/bin/sh`.

### Key POSIX Restrictions:
1. **Arrays**: POSIX does NOT support arrays.
2. **Double Brackets**: Use `[ ]` instead of `[[ ]]`.
3. **Number Comparison**: Use `-eq`, `-lt`, etc. (No `(( ))`).
4. **Substitution**: No `source` (use `. script.sh`).

---

## ⚙️ Bash Extensions (Bashisms)
Bash provides "Quality of Life" features that make scripting faster but break portability.
- **Arrays**: `declare -a MY_ARRAY`.
- **Associative Arrays**: `declare -A CONFIG`.
- **Process Substitution**: `<(command)`.
- **Brace Expansion**: `{1..10}`.

---

## 🏛️ Comparison Matrix

| Feature | POSIX (`sh`) | Bash (`bash`) |
| :--- | :--- | :--- |
| **Shebang** | `#!/bin/sh` | `#!/bin/bash` |
| **Function Definition**| `func() { ... }` | `function func { ... }` |
| **Comparison** | `[ "$a" = "$b" ]` | `[[ $a == $b ]]` |
| **Substring** | `echo ${v%suffix}` | `echo ${v:0:5}` |
| **Math** | `expr $a + $b` | `(( sum = a + b ))` |

---

## 🛡️ SRE Global Best Practices
1. **Lowest Common Denominator**: If you are writing a script for a container image (like Alpine), stick to **POSIX**.
2. **Feature-Rich Scripts**: If your script is a complex configuration engine for high-tier servers (Ubuntu/RHEL), use **Bash**.
3. **Verification**: Use the `checkbashisms` tool to identify non-POSIX code in your `/bin/sh` scripts.

---

## 🧪 Real-World Troubleshooting
**Scenario**: "My script works on my laptop (Mac) but fails on the production k8s node."
- **Root Cause**: macOS uses `zsh` or a different `bash` version, while slim containers use `ash` or `sh`.
- **Solution**: Change the shebang to `#!/bin/sh` and replace all `[[ ]]` with `[ ]`.

---

## ❓ Interview "Deep-Cut" Questions
1. **Explain why `[[ ]]` is safer than `[ ]` in a Bash environment.**
2. **How do you perform basic arithmetic in a POSIX-compliant way without `(( ))`?**
3. **What is the risk of using `#!/bin/bash` in an environment where Bash is installed in `/usr/local/bin`?**
4. **Describe a scenario where you would intentionally choose `sh` over `bash` for a DevOps tool.**
5. **How does `source` differ from `.` in terms of shell compatibility?**

---
**Next Step**: [Regular Expressions Reference →](./regular-expressions-ref.md)
