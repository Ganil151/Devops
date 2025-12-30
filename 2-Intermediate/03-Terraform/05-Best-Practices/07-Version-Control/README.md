# Version Control

Treating your infrastructure like application code starts with professional use of Git.

## 🌿 Branching Strategy
- **`main`**: Reflects the current state of **Production**.
- **`staging` / `dev`**: Optional persistent branches for environment testing.
- **Feature Branches**: All changes start here. Use a Pull Request (PR) to merge.

## Best Practices
1.  **Atomic Commits**: One change per commit (e.g., "Add S3 logging" NOT "Updated 5 modules").
2.  **.gitignore**: Always ignore local state, backups, and provider binaries.
```text
# .gitignore example
*.tfstate
*.tfstate.backup
.terraform/
*.exe
terraform.tfvars (if containing secrets)
```
3.  **Pull Request Reviews**: Never merge your own code. A second pair of eyes catches logic errors and security gaps.

## Versioning Modules
- Tag your module releases using **Semantic Versioning** (e.g., `v1.2.0`).
- Use these tags when calling the module in your root configuration.

---

## 🏗️ Real-Life Scenario: The Undo Button
**Problem**: An engineer merges a change that accidentally deletes all public IP addresses. Production is unreachable.
**Solution**: Because they use Version Control, they simply run `git revert HEAD` and trigger the CI/CD pipeline. 
**Outcome**: The infrastructure is restored to the previous healthy state in minutes. Without Git, they would have had to manually undo 100 lines of HCL from memory.

---

## ❓ Interview Questions
1.  **Why should you never commit the `.terraform/` directory to Git?**
    *   *Answer*: That directory contains downloaded provider binaries (which are large and OS-specific) and local module copies. Committing it bloats the repo and breaks it for users on different Operating Systems.
2.  **What is the risk of "Long-Lived" feature branches in Terraform?**
    *   *Answer*: The real cloud infrastructure might change (Drift) while you are working on your branch. When you finally merge, your code might be incompatible with the current state of the cloud.

---

## 🧠 Quiz Snippet (5/20+)
1.  **What file prevents unwanted uploads to Git?** (`.gitignore`)
2.  **True/False: You should merge code as fast as possible without review.** (False)
3.  **Which branch should represent the "Source of Truth"?** (`main`)
4.  **Can you version-control your state file?** (NO - Use a remote backend)
5.  **What is the benefit of Descriptive Commit Messages?** (Traceability and easier auditing of changes)
