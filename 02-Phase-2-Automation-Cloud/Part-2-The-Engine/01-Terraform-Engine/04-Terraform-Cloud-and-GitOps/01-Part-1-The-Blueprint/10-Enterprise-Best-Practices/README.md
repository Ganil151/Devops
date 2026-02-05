# Enterprise Best Practices

Scaling HCP Terraform from a handful of workspaces to a global organizational standard requires more than technical knowledge—it requires a robust **<font color="#92d050">Architectural Strategy</font>**. This module defines the "Gold Standard" for managing enterprise infrastructure at scale.

---

## 🏗️ 1. Workspace Architecture: Micro-Stacks

The most common failure in enterprise Terraform is the "Monolithic Workspace." 

**Anti-Pattern**: One workspace named `production` containing the VPC, EKS Cluster, RDS Databases, and Apps. 
- **Cons**: 45-minute plan times, massive blast radius, and team friction (everyone fighting for the state lock).

**Best Practice**: The **Micro-Stack** approach.
Split infrastructure by **Lifecycle** and **Change Frequency**:
1.  **Fundamental Layer**: Networking (VPCs, Transit Gateways) - Changes rarely.
2.  **Stateful Layer**: Databases, Storage - High risk, changes cautiously.
3.  **Application Layer**: EKS, EC2, Lambdas - Changes daily by product teams.

---

## 🔐 2. Security "Guardrails" Strategy

In an enterprise, you cannot rely on trust alone. You must implement automated **<font color="#ff0000">Policy Guardrails</font>**.

- **Source Control Enforcement**: Ensure every workspace is linked to a VCS repository to provide a clear audit trail of *who* changed *what* and *why*.
- **Private Module Registry (PMR)**: Ban direct GitHub module sources in production. Force teams to use versioned modules from the PMR to ensure **<font color="#92d050">Immutability</font>**.
- **Automated Scanning**: Integrate **Run Tasks** (e.g., Snyk, Bridgecrew) between the Plan and Apply phases to detect vulnerabilities before they land in the cloud.

---

## 🌐 3. Private Network Execution: HCP Terraform Agents

Many enterprise resources (e.g., On-Prem databases, private RDS subnets) are NOT reachable from the public internet. **HCP Terraform Agents** solve this without requiring complex VPNs.

### How it works:
1.  You run the Agent as a Docker container **inside your private network**.
2.  The Agent polls HCP Terraform via **Outbound HTTPS (443)**.
3.  The Agent pulls the Terraform plan, executes it locally within your network, and pushes the logs back to the Cloud UI.

---

## 🚀 4. Real-Life Scenarios

### Scenario 1: The "Legacy" Migration
*   **The Incident**: A company moved 500 legacy apps to HCP Terraform. They initially put them all in one Organization with no Projects.
*   **The Mess**: Finding a specific workspace was impossible, and the "Recent Runs" feed was a chaotic stream of 10,000 global events.
*   **The Fix**: Refactored the Organization into **Projects** (e.g., `Retail`, `Logistics`, `HR`).
*   **Outcome**: Team focus was restored. Developers only see the workspaces that matter to them, and Platform Admins can apply global policies per project.

### Scenario 2: The "Over-Permissive" CI/CD
*   **The Incident**: A Jenkins server was compromised. Because it used a Master Organization Token, the attacker was able to delete 200 production workspaces globally.
*   **The Fix**: Migrated to **Team Tokens** with "Least Privilege." The Jenkins server for the "Dev" team only has rights to "Plan" in the Prod project—not "Apply" or "Delete."
*   **Outcome**: The threat surface was reduced by 90%.

### Scenario 3: The "Frozen" Infrastructure
*   **The Incident**: During a peak holiday shopping season, the company needed to "Freeze" all infrastructure changes to prevent accidental outages.
*   **The Fix**: Instead of disabling Jenkins, the admin applied a **Hard Mandatory Sentinel Policy** that checks the date. If the date is between Dec 15 and Jan 2, all applies are automatically rejected.
*   **Outcome**: 100% compliance with the Change Freeze policy without manual monitoring.

---

## ❓ 5. Interview Questions (Expert Deep Dive)

1.  **What is a "Landing Zone" in the context of HCP Terraform?**
    <details>
    <summary>Show Answer</summary>
    A Landing Zone is a set of "Base" workspaces (Networking, IAM, Security, Shared Services) that provide the foundation. Individual application teams "land" their apps into this pre-configured environment in a self-service manner.
    </details>

2.  **How do you handle "Scale" when managing 1,000+ workspaces?**
    <details>
    <summary>Show Answer</summary>
    By using **Admin-as-Code**. You don't use the UI. You create another Terraform workspace (The "Admin Workspace") that uses the `tfe` provider to programmatically create, update, and manage the other 1,000 workspaces.
    </details>

3.  **Why is "Auto-Apply" generally considered an anti-pattern for Production?**
    <details>
    <summary>Show Answer</summary>
    It removes the final "Human in the Loop" verification. In production, a successful plan doesn't always mean a safe change (e.g., an accidental database deletion). A manual "Confirm" step acts as a final sanity check against high-risk logic errors.
    </details>

4.  **When should you use a TFC Agent versus TFC Cloud Runners?**
    <details>
    <summary>Show Answer</summary>
    Use **Cloud Runners** for public resources (AWS/Azure/GCP) where no network barriers exist. Use **Agents** when you need to manage resources inside a private VPC, an On-Prem data center, or an air-gapped environment.
    </details>

5.  **What is the benefit of "VCS Run Triggers" for modular architecture?**
    <details>
    <summary>Show Answer</summary>
    They allow for **Automated Cascades**. If you update the "Core Networking" workspace, TFC can automatically trigger a plan in the "Sub-App" workspaces to ensure they are still compatible with the new network topology.
    </details>

---

## 🧠 6. Knowledge Check (Quiz)

### Strategy & Scale
1.  **The "Blast Radius" of a workspace is reduced by:**
    - [ ] Adding more resources to it.
    - [x] **Splitting it into smaller, logically isolated workspaces**.
2.  **To manage HCP Terraform settings as code, use the:**
    - [ ] `aws` provider.
    - [x] **`tfe` provider**.
3.  **The primary purpose of "Projects" is:**
    - [x] **Organizing workspaces and centralizing RBAC**.
    - [ ] Speeding up deployments.

### Operations & Security
4.  **TFC Agents connect to the cloud via:**
    - [ ] Inbound SSH.
    - [x] **Outbound HTTPS (polling)**.
5.  **Semantic Versioning for modules helps prevent:**
    - [ ] Cost increases.
    - [x] **Breaking changes** from reaching production unexpectedly.
6.  **"Verified" modules are curated by:**
    - [ ] HashiCorp.
    - [x] **Your internal Platform/Security team**.

---

## 📖 7. Final Summary Checklist

✅ **Project-Based RBAC**: Group your workspaces and assign permissions at the project level.
✅ **Micro-Stacks**: Keep your plan times under 5 minutes by splitting layers.
✅ **Admin-as-Code**: Manage your TFC Org with the `tfe` provider.
✅ **Verified Registry**: Centralize your internal best practices in the Private Module Registry.
✅ **Dynamic Credentials**: Transition to OIDC to eliminate long-lived cloud keys.
✅ **Automated Governance**: Use Sentinel or OPA as a "Safety Net" for all production deployments.

---
**Module Status**: ✅ Comprehensive Verified
**Last Updated**: 2026-01-08