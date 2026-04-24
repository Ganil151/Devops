# 📐 Part 1: The Blueprint (Foundations)

> **"A Junior writes scripts that work when everything is perfect. A Senior writes scripts that work when everything is falling apart."**

Welcome to **The Blueprint**. This is where we lay the foundation for robust shell automation. We move from one-liners to structured, defensive engineering.

## 🛣️ The Curriculum

### [01-Shell-Fundamentals](./01-shell-fundamentals/)
**The Objective**: Master the core syntax and safety rules.
*   **Key Concepts**: 
    *   **The Shebang**: `#!/usr/bin/env bash` (Portability).
    *   **Strict Mode**: `set -euo pipefail` (Safety).
    *   **Variables & Quoting**: Understanding why `rm $1` is dangerous but `rm "$1"` is safe.

### [02-Reference-Library](./02-reference-library/)
**The Objective**: A quick-lookup for the most common Bash patterns.
*   **Contents**: Cheat sheets for loops, conditionals, signal traps, and exit codes.

---

## 🚀 The Difference: Junior vs. Senior

| Feature | Junior Approach | Principal approach |
|:---|:---|:---|
| **Errors** | Script keeps running after a command fails. | `set -e` crashes the script at the first error. |
| **Variables** | Uses `$NAME` | Uses `"${NAME}"` (with quotes and braces). |
| **Logic** | Manual checks. | Functions with local variables and clear exit codes. |

---

## 🛠️ The "Strict Mode" Checklist

Every production script MUST include these lines:
```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
```

---
**Status**: ✅ Organized (2026-02-02)
