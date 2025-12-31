# Enterprise Best Practices

Scaling from 1 to 100 workspaces requires rigorous architecture. This module defines the "Gold Standard" for enterprise TFC setups.

## 1. Architecture Strategy

### Monolith vs. Micro-Workspaces
*   **Anti-Pattern**: One workspace named `prod` containing VPC, EKS, RDS, and Apps. takes 45 minutes to plan.
*   **Best Practice**: Split by **Lifecycle** and **Risk**.
    *   **Networking** (Changes yearly, High Risk).
    *   **Data/Stateful** (Changes monthly, High Risk).
    *   **Compute/App** (Changes daily, Low Risk).

### Landing Zones
A Landing Zone is the foundational infrastructure where applications land.
*   **Structure**:
    ```mermaid
    graph TD
        Core[Core - TFC Admin] -->|Manages| Net[Networking Hub]
        Net -->|Peered| App1[App 1 Spoke]
        Net -->|Peered| App2[App 2 Spoke]
        
        Core -->|Policies| All[All Workspaces]
    ```

---

## 2. Naming Conventions

If you can't tell what a workspace does by its name, you have failed.
**Standard**: `<System>-<Env>-<Component>`

| part | example |
| :--- | :--- |
| **System** | `billing` |
| **Env** | `prod`, `dev`, `stage` |
| **Component** | `networking`, `app`, `db` |

**Result**: `billing-prod-networking`, `billing-dev-app`.

---

## 3. Agent Strategy

TFC Runners are great (SaaS), but they can't reach your private RDS instance or On-Prem datacenter.

### TFC Agents
*   **What**: A Docker container (binary) you run in your private network.
*   **How**: It polls TFC API for work (Outbound HTTPS 443). No Inbound ports required.
*   **Use Case**: Deploying to private subnets without public IPs.

---

## 4. Real-Life Scenarios

### Scenario 1: "The 1-Hour Apply"
**Problem**: A customer had a "Monolith" workspace with 4,000 resources. `terraform plan` took 60 minutes.
**Solution**: Split into 4 layers (Network, Security, Data, App).
**Result**: `terraform plan` for the App layer (where 90% of changes happen) now takes 2 minutes.

### Scenario 2: "The Shadow Agent"
**Problem**: Security team refused to open firewall ports for TFC to reach the on-prem VMWare cluster.
**Solution**: Deployed **TFC Agents** inside the firewall. Validated that only outbound TLS was needed.
**Result**: Authorized deploy path established without firewall holes.

### Scenario 3: "Tagging Taxonomy"
**Problem**: CFO could not allocate $1M cloud spend.
**Solution**:
1.  Defined Standard Tags in a Global Variable Set.
2.  Enforced presence of `CostCenter` tag via Hard Mandatory Sentinel Policy.
3.  Visualized spend via TFC Cost Estimation exports.

---

## 5. ❓ Interview Questions

1.  **Why split state files (workspaces)?**
    *   **Answer**: To reduce "Blast Radius" (an error deletes everything) and improve "Plan Performance" (speed).

2.  **What is the "Admin Workspace" pattern?**
    *   **Answer**: Using a TFC workspace to manage TFC itself (creating users, teams, and other workspaces) using the `tfe` provider. Admin-as-Code.

3.  **How do you handle shared modules in Enterprise?**
    *   **Answer**: Enforce usage of the Private Module Registry. Ban direct Git sources (e.g., `git::...`) in Production to ensure version immutability.

4.  **TFC Agents vs VPN?**
    *   **Answer**: Agents are easier. They don't require site-to-site VPNs or complex routing, just internet access.

5.  **What is the maximum recommended resources per workspace?**
    *   **Answer**: Soft limit around 500-1000 resources. Beyond that, API limits and graph calculation time degrade performance significantly.

6.  **How do you backup TFC?**
    *   **Answer**: TFC SaaS is managed by HashiCorp. For your own peace of mind, you can have a "State Backup" job that exports state JSONs to a cold storage S3 bucket periodically.

7.  **What is "Run Task" validation?**
    *   **Answer**: Injecting Snyk or Wiz scans *between* Plan and Apply. If the vulnerability scan fails, the Apply is blocked.

8.  **Ephemeral Workspaces?**
    *   **Answer**: Creating a workspace for a Pull Request preview environment and destroying it automatically when the PR merges.

9.  **Should every team have their own Organization?**
    *   **Answer**: Generally No. One Organization with strict RBAC/Projects allows for shared governance (Sentinel). Multiple Orgs fragments visibility.

10. **How do you handle "Orphaned" resources?**
    *   **Answer**: Resources deleted from config but still in cloud? TFC doesn't auto-delete them unless you run Apply. Use Drift Detection to find them.

---

## 6. 🧠 Knowledge Check (Quiz)

### Architecture
1.  **Blast Radius reduction is achieved by:**
    *   [x] Breaking monoliths into smaller workspaces.
    *   [ ] Increasing workspace size.

2.  **Naming conventions aid in:**
    *   [x] Discoverability and Filtering.
    *   [ ] Networking.

3.  **TFC Admin Pattern uses:**
    *   [x] The `tfe` provider.
    *   [ ] The `aws` provider.

4.  **Landing Zones provide:**
    *   [x] Standardized compilation of core services (Network/Identity) for apps to consume.
    *   [ ] A place to land planes.

### Agents & Ops
5.  **TFC Agents require:**
    *   [x] Outbound Internet HTTPS.
    *   [ ] Inbound SSH.

6.  **To reach Private Subnets:**
    *   [x] Use Agents.
    *   [ ] Use Public IPs on everything.

7.  **Admin-as-Code allows:**
    *   [x] Version controlling your Team membership and Access.
    *   [ ] Faster UI clicks.

8.  **Run Tasks integrate:**
    *   [x] 3rd Party Tools (Security/Cost) into the pipeline.
    *   [ ] Internal bash scripts.

9.  **If `plan` takes 60 minutes:**
    *   [x] Your state file is too big. Refactor.
    *   [ ] Buy a faster laptop.

10. **Single Organization strategy handles:**
    *   [x] Centralized Policy and Governance.
    *   [ ] Billing separation (use Tags for that).

### Scenarios
11. **"Shadow IT" is combated by:**
    *   [x] Making the "Happy Path" (TFC) easier than the "Shadow Path".
    *   [ ] Screaming.

12. **For compliance in regulated industries:**
    *   [x] Use Sentinel to enforce encryption and logging.
    *   [ ] Trust developers.

13. **Ephemeral Environments:**
    *   [x] Reduce costs by existing only during testing.
    *   [ ] Are permanent.

14. **Why ban `git::` sources in Prod?**
    *   [x] Because tags in Git can be moved. PMR versions are immutable.
    *   [ ] Because Git is slow.

15. **Cross-Workspace dependencies are managed via:**
    *   [x] Run Triggers and Remote State Data Sources.
    *   [ ] Copy-paste.

### General
16. **Enterprise TFC implies:**
    *   [x] Scale, Governance, and Automation.
    *   [ ] Just hosting state.

17. **Is "ClickOps" compatible with Enterprise TFC?**
    *   [ ] Yes.
    *   [x] No, it causes drift.

18. **Can you auto-destroy workspaces?**
    *   [x] Yes, via API/CLI automation (e.g., nightly cleanup).
    *   [ ] No.

19. **The golden rule of modules:**
    *   [x] Create reusable, versioned building blocks.
    *   [ ] Create one mega-module.

20. **Who owns the "Platform"?**
    *   [x] The Platform/SRE Team (enabling Product Teams).
    *   [ ] Everyone.
