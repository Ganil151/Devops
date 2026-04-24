# terraform fmt

## 📋 Overview

`terraform fmt` is the official **<mark style="background:#d4b106">code formatter</mark>** for Terraform. It automatically rewrites your `.tf` files to follow a consistent style and canonical format.

---

## 🎯 Purpose

- Enforcing a uniform coding style across a team
- Improving code readability
- Minimizing "noisy" diffs in Pull Requests (e.g., whitespace changes)
- Standardizing indentation and alignment of equals signs (=)

---

## 📝 Basic Syntax

```bash
terraform fmt [options] [DIR]
```

---

## 🚀 Common Usage Examples

### 1. Format Current Directory
```bash
terraform fmt
```
*Scans the current directory and formats all `.tf` files.*

### 2. Recursive Formatting
```bash
terraform fmt -recursive
```
*Formats files in the current directory and all subdirectories.*

### 3. Check Only (CI/CD Mode)
```bash
terraform fmt -check
```
*Returns an exit code of 3 if files need formatting, without actually changing them. Perfect for build pipelines.*

### 4. Show the Diffs
```bash
terraform fmt -diff
```
*Displays exactly what changes would be made to the formatting.*

---

## 🛡️ Technical Standards applied by `fmt`

- **Indentation**: 2 spaces (no tabs).
- **Alignment**: Equals signs (=) in a block are aligned vertically.
- **Spacing**: Consistent spacing around arguments and in maps.
- **Lists**: Standardized formatting for multi-line lists.

---

## 🛠️ Real-World Scenarios

### Scenario 1: Pre-Commit Hygiene
An engineer has their own favorite way of spacing code. Without `fmt`, the GitHub repository becomes a mess of different styles. By requiring `fmt`, every file looks like it was written by the same person.

### Scenario 2: Precise Code Reviews
"If the code isn't formatted, the review won't start."
Many teams use a GitHub Action that runs `terraform fmt -check`. If it fails, the PR is automatically blocked. This ensures that reviewers focus on **<font color="#92d050">logic</font>** rather than **<font color="#92d050">whitespace</font>**.

---

## ⚙️ Important Flags

| Flag | Description | Use Case |
|------|-------------|----------|
| `-check` | See if formatting is needed (no write) | CI/CD Linting |
| `-recursive` | Scans all sub-folders | Large monolithic repos |
| `-diff` | Shows the formatting changes | Debugging style issues |
| `-no-color` | Disables colored output | Generating log files |

---

## 🎓 Best Practices

1. **Format before you Commit**: Make it a habit to type `terraform fmt` before every `git add`.
2. **Editor Integration**: Most modern IDEs (VS Code with HashiCorp Extension) can run `fmt` automatically whenever you save a file.
3. **Pipeline Enforcement**: Always include `-check` in your CI pipeline to prevent "unformatted" code from leaking into the main branch.

---

## 📖 Summary

**terraform fmt** is simple but powerful. A clean, consistently formatted codebase reduces cognitive load and allows teams to scale faster. It is the gold standard for **<mark style="background:#d4b106">Clean IaC</mark>**.

---

**[⬅️ Back to Commands README](readme.md)** | **[Previous: terraform import](07-import.md)** | **[Next: terraform show](10-show.md)**
