# Enterprise Best Practices

Scaling Terraform to hundreds of engineers and thousands of resources requires a strategic approach to HCP Terraform.

## 1. Multi-Workspace Architecture
- **Micro-State**: Don't put everything in one giant workspace. Split by component (Network, DB, App) and Environment (Dev, Test, Prod).
- **Communication**: Use `terraform_remote_state` data sources or **Workspace Outputs** to share data between them.

## 2. Organization Governance
- **Variable Sets**: Centralize all provider credentials.
- **Policy Libraries**: Maintain a separate Git repo for Sentinel/OPA policies and link it to the Organization.
- **Teams**: Use SSO groups (e.g., AD Groups) to manage access automatically.

## 3. Workflow Standardization
- **VCS for Everything**: Ban CLI-driven applies for production. Every change *must* go through a Pull Request and a Policy Check.
- **Module Versioning**: Never use `source = "./local/path"`. Always use the Private Module Registry with version pinning (e.g., `version = "1.2.0"`).

## 4. The "Security-First" Pipeline
1.  **Commit**: Code is pushed.
2.  **Lint**: `tflint` checks the logic.
3.  **Plan**: TFC generates the plan.
4.  **Scan**: Run Task (e.g., Snyk) checks for vulnerabilities.
5.  **Policy**: Sentinel/OPA checks for compliance.
6.  **Human**: SRE reviews and clicks "Apply."

---

## 🏗️ Real-Life Scenario: The Global Scale-Up
**Problem**: A company expands from 1 office to 5 global regions. They start hitting "State Lock" issues daily because 20 developers are trying to update the same monolithic state file in TFC.
**Solution**: They refactor into 15 Workspaces (3 components x 5 regions). 
**Outcome**: Teams in London can update their Network without blocking teams in Tokyo. State locks are no longer a bottleneck.

---

## ❓ Interview Questions
1.  **Why is it better to have many small workspaces instead of one large one?**
    *   *Answer*: To reduce the "Blast Radius" (a mistake in one area won't break everything), decrease execution time (plans are faster), and minimize concurrency bottlenecks (state locks).
2.  **How do you share Cloud Credentials securely across many teams?**
    *   *Answer*: Using **Variable Sets** at the Organization level, limited to specific projects or teams, and marked as **Sensitive**.

---

## 🧠 Final Module Quiz (5/50+)
1.  **What is the #1 rule for production safety in TFC?** (Pin module versions and use VCS workflow)
2.  **True/False: You should use different TFC Organizations for Dev and Prod.** (Optional, but often better to use one Org with strict RBAC)
3.  **What is a "Project" in TFC?** (A container for grouping related Workspaces)
4.  **How do you reduce the Blast Radius?** (Smaller workspaces)
5.  **What tool is best for managing TFC at scale?** (The `tfe` Terraform provider - manage TFC *with* Terraform!)
