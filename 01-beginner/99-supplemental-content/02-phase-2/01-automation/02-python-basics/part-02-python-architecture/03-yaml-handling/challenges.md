# 🎯 YAML Handling: Config Blueprint Challenges

> **"If JSON is for machines, YAML is for humans. These challenges test your ability to build readable infrastructure blueprints."**

---

## 🏆 Challenge 1: The DRY Infrastructure Template
**Difficulty**: ⭐ Beginner  
**Estimated Time**: 15 minutes

### Objective
Minimize repetition in a Cloud configuration using **Anchors and Aliases**.

### Requirements
- Create a YAML representing 3 environments (`dev`, `staging`, `prod`).
- Use an **Anchor** (`&`) for a base resource config (CPU: 1, RAM: 2Gi).
- Use **Aliases** (`*`) to reuse that base config in all environments.
- Override the `prod` config to use CPU: 4 instead.

---

## 🏆 Challenge 2: The Multi-Resource Deployment
**Difficulty**: ⭐⭐ Intermediate  
**Estimated Time**: 30 minutes

### Objective
Parse a multi-document Kubernetes manifest and perform "Pre-flight Checks".

### Requirements
- Read a YAML string containing a `Service`, a `Deployment`, and a `ConfigMap` separated by `---`.
- Loop through the documents and verify:
    1.  All resources have a `metadata.name`.
    2.  The `Deployment` has at least 3 `replicas`.
- Print a warning if any check fails.

---

## 🏆 Challenge 3: The Secret Injector
**Difficulty**: ⭐⭐⭐ Advanced  
**Estimated Time**: 45 minutes

### Objective
Create a custom YAML tag `!env` that pulls values from environment variables at runtime.

### Requirements
- Register a custom constructor for the `!env` tag.
- Create a YAML file that uses `database_password: !env DB_PASS`.
- Set the `DB_PASS` environment variable in Python (`os.environ`).
- Load the YAML and verify the password was correctly injected.

---

## ✅ Completion Checklist
- [ ] Challenge 1: DRY Infrastructure Template
- [ ] Challenge 2: Multi-Resource Deployment
- [ ] Challenge 3: Secret Injector
