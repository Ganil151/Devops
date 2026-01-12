![HCP Terraform Architecture](tfc_architecture.png)

# Introduction and Architecture

HCP Terraform (formerly Terraform Cloud) is HashiCorp's managed service offering that provides a collaborative environment for teams using Terraform. While Terraform OSS is powerful for local execution, HCP Terraform provides the structural "wrapper" needed to run Infrastructure as Code (IaC) safely, at scale, and in compliance with enterprise security standards.

---

## 🏗️ 1. Architecture: The Remote Paradigm

In the traditional **OSS Workflow**, the Terraform binary runs on your local machine, and you manually manage backends (like S3) for state storage. In **HCP Terraform**, the execution moves to the cloud.

### The Unified Control Plane
HCP Terraform acts as the centralized control plane. It orchestrates runners, manages state, and provides a unified interface for all team members.

### The Execution Process
1.  **VCS Trigger**: A developer pushes a commit or opens a Pull Request in GitHub, GitLab, or Bitbucket.
2.  **Webhook & Context**: HCP Terraform receives a webhook and prepares the workspace context (variables, state, and code).
3.  **Plan Runner (Ephemeral VM)**: TFC spins up an isolated, temporary VM. It clones the specific commit, downloads the required provider plugins, and executes `terraform plan`.
4.  **Speculative Plans**: If the run was triggered by a PR, a "Speculative Plan" is generated—this is for review only and cannot be applied to infrastructure.
5.  **Policy & Ethics Check**: Sentinel or OPA (Open Policy Agent) scans the plan against corporate rules (e.g., "No open S3 buckets").
6.  **Apply Runner**: Once approved, a second runner executes the actual changes in the cloud (AWS/Azure/GCP).
7.  **Managed State**: The state is updated, encrypted at rest, and stored securely within the platform.

---

## 📊 2. Terraform OSS vs. Cloud vs. Enterprise

| Feature | Open Source (CLI) | Terraform Cloud (HCP) | Terraform Enterprise (TFE) |
| :--- | :--- | :--- | :--- |
| **Hosting** | Local / Self-Managed | SaaS (HashiCorp) | Self-Hosted (Private Cloud) |
| **State Storage** | Manual (S3/GCS) | Managed & Versioned | Managed & Versioned |
| **Execution** | Local binary | Managed Cloud Runners | Private Dedicated Runners |
| **Team Collaboration** | Manual (Stateless) | Real-time Collaboration | SSO / RBAC / Auditing |
| **Governance** | None (Code Review) | Sentinel Policy as Code | Sentinel & OPA |
| **Private Registry** | Local modules only | Organization-wide Registry | Full Enterprise Registry |

---

## 🧩 3. Key Concepts & Workspace Models

### The Workspace (TFC vs CLI)
In CLI-land, a "workspace" is just a named state file. In HCP Terraform, a **Workspace** is a robust container that encapsulates:
- **State History**: Every version of your state file ever created.
- **Variables**: Both Terraform variables (`.tfvars`) and Environment variables (`AWS_ACCESS_KEY`).
- **Run History**: A complete audit trail of every plan and apply attempt.
- **Access Control**: Specific permissions for who can plan, apply, or read state.

### Operational Workflows
HCP Terraform supports three primary ways to trigger runs:
1.  **VCS-Driven**: (Most common) Triggered by Git commits or PRs. Best for mature CI/CD.
2.  **CLI-Driven**: You run `terraform plan` on your laptop, but the execution happens in the Cloud.
3.  **API-Driven**: Integrated into custom developer portals or existing CI tools (Jenkins/CircleCI).

---

## 🚀 4. Real-Life Scenarios

### Scenario 1: The "Ghost Resource" and Laptop Failure
*   **The Problem**: A developer was applying a complex multi-region stack from their home WiFi. The connection dropped midway through a 30-minute run.
*   **The OSS Result**: Local state was out of sync. Resources were created in AWS but not tracked in any state file.
*   **The HCP Solution**: The run happened on a Cloud Runner. The developer's laptop only "watched" the logs. When the WiFi died, the Runner completed the job and saved the state perfectly.

### Scenario 2: The Security Breach (Sensitive Variables)
*   **The Problem**: A junior dev accidentally committed a `.tfvars` file containing production RDS passwords to a public repo.
*   **The HCP Solution**: Credentials are stored in the **Workspace Variables** marked as **"Sensitive"**. They are never visible in the UI after saving and are never committed to code.

---

## ❓ 5. Interview Questions (Expert Deep Dive)

1.  **Compare TFC Workspaces with CLI Workspaces.**
    <details>
    <summary>Show Answer</summary>
    CLI workspaces are just separate state files in one directory used to manage different environments from one code base. TFC workspaces are comprehensive management containers that include state history, variables, run logs, VCS integrations, and RBAC permissions.
    </details>

2.  **How do you handle secrets in HCP Terraform?**
    <details>
    <summary>Show Answer</summary>
    By using **Sensitive Variables** at the workspace or Variable Set level. They are encrypted at rest using Vault and are "write-only" in the UI. For dynamic secrets, HCP Terraform integrates with HashiCorp Vault via the Vault provider or OIDC authentication.
    </details>

3.  **What is the benefit of a "Speculative Plan"?**
    <details>
    <summary>Show Answer</summary>
    It allows teams to see the infrastructure impact of a Pull Request before merging it. Speculative plans are non-apply-able, ensuring that documentation/review happens without any risk of accidental changes to the real cloud environment.
    </details>

4.  **Explain the role of HCP Terraform Agents.**
    <details>
    <summary>Show Answer</summary>
    Agents act as a bridge between the TFC SaaS platform and private infrastructure (like on-prem data centers or private VPCs) by pulling jobs via outbound-only HTTPS, removing the need for complex inbound firewall rules.
    </details>

5.  **How does TFC prevent "concurrent runs" on the same state?**
    <details>
    <summary>Show Answer</summary>
    HCP Terraform uses a centralized queue and state locking mechanism. Only one "Apply" run can be active at a time. If another run is triggered, it is placed in the queue and must wait for the current run to complete or be cancelled.
    </details>

---

## 🧠 6. Knowledge Check (Quiz)

### Architecture & Workflows
1.  **HCP Terraform Runners are:**
    - [x] Ephemeral VMs created for a single run and destroyed after.
    - [ ] Long-running servers you must maintain.
2.  **Which workflow requires running Terraform commands locally?**
    - [ ] VCS-Driven.
    - [x] **CLI-Driven**.
3.  **HCP Terraform state is stored in:**
    - [ ] A user-managed S3 bucket.
    - [x] Internal, managed encrypted storage.

### Governance & Security
4.  **Sentinel and OPA are used for:**
    - [ ] Speeding up runs.
    - [x] **Policy as Code enforcement**.
5.  **"Sensitive" variables are:**
    - [x] Write-only in the Web UI.
    - [ ] Visible to everyone in the project.
6.  **To chain workspaces together (A triggers B), you use:**
    - [ ] Depends_on.
    - [x] **Run Triggers**.

---

## 📖 7. Final Summary Checklist

✅ **Move execution to the Cloud**: Standardize environments by running Terraform on TFC Runners.
✅ **Secure your Variables**: Mark all passwords and tokens as "Sensitive" immediately.
✅ **Leverage Speculative Plans**: Use PR-triggered runs to catch errors before they hit production.
✅ **Use Variable Sets**: Avoid repeating common credentials across multiple workspaces.
✅ **Implement RBAC**: Ensure the principle of least privilege by using Projects and Teams.

---
**Module Status**: ✅ Comprehensive Verified
**Last Updated**: 2026-01-08