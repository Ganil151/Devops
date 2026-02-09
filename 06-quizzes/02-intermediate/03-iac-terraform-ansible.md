# IaC: Terraform & Ansible Mastery

Standardizing infrastructure through code and configuration management.

---

## 🏗️ Part 1: Terraform (Provisioning)

### [Intermediate] What happens if two developers run `terraform apply` concurrently on the same remote backend?
- [ ] A) Terraform merges the changes automatically.
- [ ] B) The last write wins and overwrites the first.
- [x] C) Without state locking (e.g., via DynamoDB), the state file can become corrupted. With locking, the second run will fail or wait.
- [ ] D) Terraform creates a `terraform.tfstate.conflict` file.

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C
**Why?** State locking is a critical safety feature. It prevents two processes from modifying the state concurrently, which would lead to a non-deterministic state and potential resource duplication or deletion.
**Certification Alignment:** HashiCorp Certified: Terraform Associate
</details>

---

## 🛠️ Part 2: Ansible (Configuration)

### [Junior] What is the difference between an Ansible "Module" and a "Playbook"?
- [ ] A) They are the same thing.
- [ ] B) Modules are written in YAML, Playbooks in Python.
- [x] C) A Module is a single unit of work (e.g., `apt`), while a Playbook is a collection of plays that organize modules.
- [ ] D) Playbooks are only for Windows.

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C
**Why?** Modules are the "tools" in the toolbox (idempotent units), while Playbooks are the "instruction manual" that tells Ansible which tools to use and when.
**Certification Alignment:** EX294 (Red Hat Certified Engineer)
</details>

---

## 🏆 Master Answer Key

| Question ID | Difficulty | Answer | Topic |
| :--- | :--- | :--- | :--- |
| T-01 | Intermediate | C | Terraform State |
| A-01 | Junior | C | Ansible Basics |
