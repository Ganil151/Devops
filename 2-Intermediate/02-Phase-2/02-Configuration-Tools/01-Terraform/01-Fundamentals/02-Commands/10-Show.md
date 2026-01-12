# terraform show

## 📋 Overview

`terraform show` is the primary command for **<mark style="background:#d4b106">Infrastructure Inspection</mark>**. It provides a human-readable (or machine-readable) view of the current state file or a specific saved plan file.

---

## 🎯 Purpose

- Inspecting the current state of resources in high detail
- Verifying the contents of a saved plan file before application
- Debugging resource attributes that are "known after apply"
- Auditing the configuration of managed infrastructure

---

## 📝 Basic Syntax

```bash
terraform show [options] [path]
```

---

## 🚀 Common Usage Examples

### 1. View Current State
```bash
terraform show
```
*Outputs a detailed text representation of every attribute of every resource in the current state.*

### 2. Inspect a Saved Plan
```bash
terraform plan -out=tfplan
terraform show tfplan
```
*Allows you to re-review exactly what a plan file will do without re-calculating the plan.*

### 3. Machine-Readable State/Plan (JSON)
```bash
terraform show -json tfplan > plan_details.json
```
*Essential for policy-as-code tools (like OPA or Sentinel) to analyze a plan before it's applied.*

---

## ⚙️ Text vs JSON Output

| Detail | Text (Default) | JSON (`-json`) |
|--------|----------------|----------------|
| **Primary Audience** | Humans | Machines/Security Tools |
| **Complexity** | Easy to read | Requires parsing (jq) |
| **Completeness** | Full details | Includes internal metadata |

---

## 🛠️ Real-World Scenarios

### Scenario 1: The Deep Debug
Your RDS instance is failing to connect. You run `terraform show` to find the hidden, computed values like the exact DNS endpoint and port that Terraform assigned.

### Scenario 2: Policy Enforcement
A security team requires that no S3 buckets are public. They run a script that:
1. Generates a plan.
2. Runs `terraform show -json tfplan`.
3. Checks if any `aws_s3_bucket` has a public access block set to false.
*This prevents security violations before they happen.*

---

## ⚙️ Important Flags

| Flag | Description | Use Case |
|------|-------------|----------|
| `-json` | Output in JSON format | CI/CD validation |
| `-no-color` | Disable terminal colors | Generating audit logs |

---

## 🎓 Best Practices

1. **Plan Review**: Always use `terraform show <planfile>` in production pipelines to verify that the file being applied is the correct one.
2. **Use JQ**: When using `-json`, pipe the output to [jq](https://stedolan.github.io/jq/) to find specific values quickly.
3. **Audit Trails**: Periodically run `terraform show -json` and archive the output as a point-in-time snapshot of your infrastructure's true state.

---

## 📖 Summary

**terraform show** is the source of truth for your state. It reveals the **<font color="#92d050">hidden details</font>** of your cloud resources and provides the data necessary for **<font color="#92d050">automated security and compliance</font>** checks.

---

**[⬅️ Back to Commands README](README.md)** | **[Previous: terraform fmt](09-Fmt.md)** | **[Next: terraform output](11-Output.md)**
