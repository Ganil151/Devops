# Local vs. Remote State

Deciding where to store your state file is a critical architectural decision.

## Local State
By default, Terraform stores state in a file called `terraform.tfstate` in the same directory as your code.
- **Pros**: Easy setup, no dependencies, fast for solo development.
- **Cons**: No team collaboration, no locking (risk of corruption), state lost if the laptop is stolen/wiped.

## Remote State
Remote state is stored in a shared service like AWS S3, Azure Blob, or HashiCorp Cloud.
- **Pros**: Shared source of truth, state locking, automatic backups, and high security.
- **Cons**: Requires initial setup of a "Backend."

## Comparison Table

| Feature | Local State | Remote State |
| :--- | :--- | :--- |
| Collaboration | Manual only (Risky) | Native / Real-time |
| Locking | None | Supported (e.g. via DynamoDB) |
| Security | Depends on OS | Encryption at rest/transit |
| Backups | Manual | Automatic versioning |

---

## 🏗️ Real-Life Scenario: The Two-Engineer Conflict
**Problem**: Engineers Alice and Bob are both working on the same VPC using local state. Alice creates a subnet and Bob creates a gateway. Because they can't share the same file, Bob's state doesn't "know" about Alice's subnet. When Alice merges Bob's code, her state thinks those resources don't exist.
**Solution**: Use a **Remote Backend** (S3). Now, Bob's changes are immediately written to S3, and Alice's local Terraform client reads the latest state before doing anything.

---

## ❓ Interview Questions
1.  **Why is remote state preferred for production environments?**
    *   *Answer*: It enables team collaboration, provides a locking mechanism to prevent concurrent runs, and ensures state is encrypted and backed up.
2.  **Can you work with local and remote state at the same time?**
    *   *Answer*: No, a project uses exactly one backend at a time.

---

## 🧠 Quiz Snippet (5/20+)
1.  **What is the risk of two people running Terraform on local state?** (State corruption or resource duplication)
2.  **True/False: Remote state supports encryption.** (True)
3.  **Does local state support locking?** (No)
4.  **Where is local state stored by default?** (Working directory)
5.  **What is the core problem solved by Remote State?** (Team collaboration and Source of Truth consistency)
