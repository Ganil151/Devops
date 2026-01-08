![TFC Architecture](../01-Introduction-and-Architecture/tfc_architecture.png)

# Advanced Features

HCP Terraform extends far beyond simple state storage. It provides a suite of advanced **<font color="#92d050">Day 2 Operations</font>** tools designed to maintain environmental health, control spiraling cloud costs, and enable internal self-service through a centralized module ecosystem.

---

## 🏗️ 1. Drift Detection & Continuous Validation

In traditional Terraform, you only discover that your infrastructure has changed (Drift) when someone manually runs a `plan`. HCP Terraform automates this discovery through periodic **<font color="#92d050">Health Assessments</font>**.

### How it Works:
1.  **Scheduled Check**: HCP Terraform triggers a non-destructive refresh of the state file every 24 hours (configurable).
2.  **Comparison**: It compares the cloud reality against the last known state.
3.  **Alerting**: If a discrepancy is found (e.g., someone manually deleted an S3 bucket or changed a Security Group rule), the workspace is marked as **"Drifted"** and sends a notification (Slack, Email, Webhook) to the team.

### Continuous Validation (The `check` block)
Starting with Terraform 1.5, you can use `check` blocks to verify environmental health.
- **Example**: A `check` block can verify that an HTTPS endpoint is returning a `200 OK` status.
- **TFC Integration**: HCP Terraform runs these checks continuously and alerts you if the "functional" health of your infrastructure degrades, even if the "state" hasn't drifted.

---

## 💰 2. Cost Estimation: Financial Governance

HCP Terraform provides visibility into the financial impact of infrastructure changes **<font color="#ffc000">before</font>** they happen.

- **The Pricing Engine**: TFC uses public pricing APIs for AWS, Azure, and GCP.
- **The Delta**: When a plan is generated, TFC calculates the monthly cost difference (e.g., "This change will increase your bill by $452.10/mo").
- **Policy Enforcement**: You can combine Cost Estimation with Sentinel or OPA to automatically block any Pull Request that exceeds a specific budget threshold (e.g., "Block all PRs that increase monthly spend by > $1,000").

---

## 📦 3. Private Module Registry (PMR)

The Private Module Registry is your organization's internal "App Store" for infrastructure. Instead of teams writing their own (often insecure) VPC or RDS code, they consume **<font color="#92d050">Verified Modules</font>** from the central registry.

### Features:
- **Semantic Versioning**: Support for `v1.0.0`, `v1.1.0`, etc., ensuring that teams can lock into stable versions.
- **Automated Docs**: TFC automatically parses your `.tf` files to generate a professional documentation UI with input/output tables and dependency maps.
- **Verification**: Mark official modules as "Verified" with a blue checkmark badge. This signals to developers that the module meets the organization's security and performance standards.

---

## 🚀 4. Real-Life Scenarios

### Scenario 1: The "ClickOps" Disaster
*   **The Incident**: During a high-pressure production outage, an engineer added an "Allow All" Firewall rule via the AWS Console to restore connectivity. They forgot to update the Terraform code afterwards.
*   **The HCP Solution**: 24 hours later, **Drift Detection** identified the unauthorized rule. It flagged the workspace as drifted and sent a Slack alert to the security team.
*   **Outcome**: The team realized the manual change was still there, backported it to code securely, and closed the security hole within minutes of discovery.

### Scenario 2: The $10,000 Typo
*   **The Incident**: A developer intended to create 5 small instances but accidentally set `count = 50` on a `c6g.metal` instance type.
*   **The HCP Solution**: The **Cost Estimation** service calculated that this single change would cost an additional $12,000 per month. A Sentinel policy immediately **Hard-Blocked** the apply.
*   **Outcome**: The company saved over $10,000 in accidental charges before the resources were ever provisioned.

---

## ❓ 5. Interview Questions (Expert Deep Dive)

1.  **Does Drift Detection automatically revert the manual cloud changes?**
    <details>
    <summary>Show Answer</summary>
    **No**. Drift Detection is an assessment and notification tool. It only alerts you that a discrepancy exists. To fix it, a human must decide whether to run a Terraform Apply (to overwrite the manual change) or update the code to match reality.
    </details>

2.  **What happens if Cost Estimation cannot find a price for a specific resource?**
    <details>
    <summary>Show Answer</summary>
    TFC will show the resource in the cost output but list the cost as **null** or **unavailable**. This often happens with third-party providers or very new/obscure cloud services (e.g., a specific AI accelerator preview) that aren't yet mapped in the engine.
    </details>

3.  **How do you publish a new version of a module to the Private Registry?**
    <details>
    <summary>Show Answer</summary>
    By pushing a **Git Tag** (e.g., `v2.1.0`) to the linked repository. HCP Terraform detects the tag via webhook, pulls the code, generates the documentation, and updates the registry version automatically.
    </details>

4.  **What is the difference between "Drift Detection" and "Continuous Validation"?**
    <details>
    <summary>Show Answer</summary>
    - **Drift Detection**: Checks if the cloud state matches the `.tfstate` file (Infrastructure integrity).
    - **Continuous Validation**: Runs custom logic (HCL `check` blocks) to verify functional health (e.g., "Is my database endpoint responding?").
    </details>

5.  **How do you enforce that a specific team ONLY uses verified modules?**
    <details>
    <summary>Show Answer</summary>
    By using a **Sentinel or OPA policy** that parses the `tfconfig` (configuration) import. The policy can reject any plan that includes resources not sourced from the Private Module Registry.
    </details>

---

## 🧠 6. Knowledge Check (Quiz)

### Operations & Health
1.  **Drift Detection identifies discrepancies between:**
    - [ ] Your local folder and Git.
    - [x] **Cloud reality and the TFC state file**.
2.  **Continuous Validation uses which HCL block?**
    - [ ] `resource`.
    - [x] **`check`**.
3.  **Automated drift checks in TFC are called:**
    - [x] **Health Assessments**.
    - [ ] Speculative Plans.

### Registry & Cost
4.  **Verified modules in the PMR are indicated by:**
    - [ ] A red flag.
    - [x] **A blue checkmark badge**.
5.  **Cost estimation estimates the price of:**
    - [x] **New resources proposed in the current Plan**.
    - [ ] The entire cloud account.
6.  **To block a run based on cost, you must combine Cost Estimation with:**
    - [ ] The TFE provider.
    - [x] **Sentinel or OPA policies**.

---

## 📖 7. Final Summary Checklist

✅ **Enable Health Assessments**: Turn on Drift Detection for all production workspaces to catch "Shadow IT."
✅ **PMR for Standards**: Centralize your organization's infrastructure patterns in the Private Module Registry.
✅ **Review Cost Deltas**: Ensure developers review the "monthly spend delta" in their PR comments.
✅ **Continuous Validation**: Use the `check` block to verify functional health beyond simple state management.
✅ **Lock Module Versions**: Always pin module sources to a specific semantic version (e.g., `v1.2.3`).

---
**Module Status**: ✅ Comprehensive Verified
**Last Updated**: 2026-01-08
