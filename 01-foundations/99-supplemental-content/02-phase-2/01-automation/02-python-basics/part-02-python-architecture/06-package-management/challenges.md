# 🎯 Package Management: Supply Chain Challenges

> **"A script is only as secure as its weakest dependency. These challenges test your ability to procure and audit your automation libraries."**

---

## 🏆 Challenge 1: The Specific Version
**Difficulty**: ⭐ Beginner  
**Estimated Time**: 10 minutes

### Objective
Install a very specific version of a package to match a production requirement.

### Requirements
- Create an environment.
- Install `requests` version `2.28.0` exactly.
- Verify the version using `pip show requests`.

---

## 🏆 Challenge 2: The Security Audit
**Difficulty**: ⭐⭐ Intermediate  
**Estimated Time**: 20 minutes

### Objective
Identify known vulnerabilities in your project dependencies.

### Requirements
- Install a few packages (e.g., `requests`, `cryptography`).
- Install the tool `pip-audit`.
- Run an audit against your current environment.
- Document any "vulns" found or report "Clean".

---

## 🏆 Challenge 3: Environment Separation (Dev vs Prod)
**Difficulty**: ⭐⭐ Intermediate  
**Estimated Time**: 25 minutes

### Objective
Manage two sets of requirements for a professional project.

### Requirements
- Create `requirements.txt` (Contains `requests`, `PyYAML`).
- Create `dev-requirements.txt` (Contains `pytest`, `black`, and **the contents of requirements.txt**).
- Hint: Use the `-r requirements.txt` flag inside your dev file.
- Verify you can install the dev file and get everything.

---

## ✅ Completion Checklist
- [ ] Challenge 1: Specific Version
- [ ] Challenge 2: Security Audit
- [ ] Challenge 3: Dev vs Prod Separation
