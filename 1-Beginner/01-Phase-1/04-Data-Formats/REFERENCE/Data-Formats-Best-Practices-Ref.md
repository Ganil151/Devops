# 🌟 Data Format Best Practices: The SRE Standard
*Version 1.0 | Designing Scalable and Validated Configurations*

---

## 📖 Overview
Data formatting is not just about syntax; it is about ensuring that infrastructure state is predictable, human-readable, and machine-validatable. These best practices provide the standards for handling complex data across DevOps toolchains.

---

## 🛡️ Validation & Integrity Standards

### Schema Enforcement
**Definition**: Using JSON Schema, XSD, or custom YAML validators to ensure that data matches a strict blueprint.
**SRE Impact**: Prevents "Broken Deployments" caused by a missing mandatory key in a config file.
**Action**: Implement validation in Git `pre-commit` hooks.

### Linting (The Syntax Guard)
**Definition**: Running tools that check for stylistic and syntactical accuracy (e.g., `yamllint`, `jsonlint`).
**Action**: CI/CD pipelines should fail if a configuration file deviates from the standard (e.g., tabs in YAML).

### Automated Formatting
**Definition**: Using formatters (like `prettier` or `black`) to ensure every engineer's configuration files look identical.
**Action**: Establish a "Source of Truth" for spacing and indentation across the organization.

---

## 🚜 Architectural Hygiene

### Flat vs. Nested Structures
**Principle**: Prefer flat structures over deep nesting.
**Why**: Deeply nested values are harder to query with `jq` or `XPath` and more prone to indentation errors.
**Bad**: `meta: config: auth: secret: key: val`
**Good**: `auth_secret_key: val`

### Configuration Injection
**Principle**: Never store secrets (API Keys, Passwords) in raw YAML/JSON files.
**Action**: Use placeholders or dynamic injection (e.g., Ansible Vault, AWS Secrets Manager).

### Comments for Intent
**Principle**: Explain the "Why" behind a value, not the "What."
**Example**:
```yaml
# Increased timeout due to slow DB response in ap-south-1
query_timeout: 60
```

---

## ⚡ Form Selection Criteria

| Format | Best For | Avoid For |
| :--- | :--- | :--- |
| **YAML** | K8s, Ansible, CI/CD, Human-readability. | Data with 10k+ rows (Slow parsing). |
| **JSON** | REST APIs, Machine-to-machine data, Logs. | Complex files requiring many comments. |
| **TOML** | App settings, CLI Tooling, flat configs. | High levels of data nesting. |
| **XML** | Enterprise SSO (SAML), SOAP, Legacy APIs. | Modern, lightweight microservices. |
| **Markdown** | Runbooks, Readmes, KBs. | Programmatic logic or data storage. |

---

## ✅ The SRE Data Checklist
- [ ] Is the YAML using 2 spaces for indentation?
- [ ] Does the JSON file pass a `jsonlint` check?
- [ ] Are all multiline strings in YAML using the correct operator (`|` vs `>`)?
- [ ] Are sensitive strings substituted with environment variables/secrets?
- [ ] Is every README using a consistent heading structure?

---
**Next Step**: [Back to YAML Deep Dive →](./YAML-Deep-Dive-Ref.md)
