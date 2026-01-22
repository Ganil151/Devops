# terraform validate

## 📋 Overview

`terraform validate` is a command used to verify whether a configuration is syntactically valid and internally consistent, regardless of any provided variables or existing state. It is a critical linting step in any Terraform workflow.

---

## 🎯 Purpose

- Check syntax of HCL files (`.tf` and `.tf.json`)
- Verify attribute names and types
- Check for missing required arguments
- Ensure all resource references are valid
- Perform static analysis without contacting APIs or state

---

## 📝 Basic Syntax

```bash
terraform validate [options]
```

---

## 🚀 Common Usage Examples

### 1. Basic Validation
```bash
terraform validate
```

### 2. Validation in CI/CD (JSON Output)
```bash
terraform validate -json
```

---

## ⚙️ Important Flags

| Flag | Description | Use Case |
|------|-------------|----------|
| `-json` | Produce output in machine-readable JSON format | CI/CD pipelines, automated linting |
| `-no-color` | Disable colored output | Log files, non-interactive shells |

---

## 🔍 What it Checks vs. What it Doesn't

| ✅ Checks (Static Analysis) | ❌ Does NOT Check (Dynamic/Runtime) |
|-----------------------------|-------------------------------------|
| Correct HCL Syntax | Cloud Provider Credentials |
| Resource Type Validity | API Availability/Connectivity |
| Required Argument Presence | Resource Name Collisions in Cloud |
| Attribute Name Correctness | Specific Value Limits (e.g., valid AMI ID) |
| Interior Module Logic | Resource Limits/Quotas |

---

## 🛠️ Real-World Scenarios

### Scenario 1: Pre-Commit Hook
Automating validation prevents broken code from ever reaching the repository.
```bash
#!/bin/bash
# .git/hooks/pre-commit
terraform fmt -check
terraform validate
```

### Scenario 2: CI/CD "Lint" Stage
A fast, lightweight check that fails the build before expensive `plan` operations occur.
```yaml
lint:
  script:
    - terraform init -backend=false
    - terraform validate
```

---

## 🎓 Best Practices

1. **Run After Init**: `terraform validate` requires the working directory to be initialized (to know about providers and modules).
2. **Use `-backend=false` for Speed**: In CI environments, you can often validate without connecting to a remote backend.
3. **Combine with `fmt`**: Always ensure code is both valid *and* properly formatted.

---

## ⚠️ Common Errors & Solutions

### Error: "Configuration is invalid"
**Cause**: Usually a typo in a resource attribute or a missing bracket.
**Solution**: Read the line number provided by the error message carefully.

### Error: "Module not installed"
**Cause**: Adding a new module block without running `init`.
**Solution**: Run `terraform init` to download the module schema.

---

## 📖 Summary

**terraform validate** is your first line of defense. It captures simple logic and syntax errors in seconds, making it the most cost-effective command for maintaining code quality.

---

**[⬅️ Back to Commands README](README.md)** | **[Previous: terraform init](01-Init.md)** | **[Next: terraform plan](03-Plan.md)**
