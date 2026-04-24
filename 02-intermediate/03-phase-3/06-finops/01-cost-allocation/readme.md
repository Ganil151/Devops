# 🏷️ 01: Cost Allocation & Governance

**[⬅️ Back to Module Index](../readme.md)** | **[Next: Optimization Strategies ➡️](../02-optimization-strategies/readme.md)**

---

# 📑 Mapping Every Cloud Dollar

In FinOps, **Visibility is King**. You cannot optimize what you cannot measure. Cost allocation is the process of mapping raw cloud usage to the business logic, teams, and products that drive the spend.

## 🧠 The Multi-Dimensional Tagging Taxonomy

A professional tagging strategy moves beyond "Owner" and "Environment". It identifies the **Business**, **Technical**, and **Financial** context of every resource.

### 1. Business Context Tags
*   `Product`: Which customer-facing service is this? (e.g., `checkout-api`)
*   `BusinessUnit`: Which internal org pays for this? (e.g., `ecommerce-team`)
*   `Project`: Is this part of a specific initiative? (e.g., `migration-2026`)

### 2. Technical Context Tags
*   `Application`: The macro-service name.
*   `Component`: The layer (e.g., `database`, `frontend`, `proxy`).
*   `ManagedBy`: The automation tool (e.g., `terraform`, `pulumi`).

### 3. Financial Context Tags
*   `CostCenter`: The specific accounting code.
*   `Chargeback`: Boolean flag to determine if the team is billed internally.

---

## 🛡️ Enforcement: The "No Tag, No Resource" Policy

Architecture-level FinOps uses **Automated Guardrails** to stop waste at the source.

### The Denial Policy (SCP)
You can use an AWS Service Control Policy (SCP) to prevent any resource creation that lacks mandatory tags.
> See the reference in `src/tagging_policy.json`.

---

## 🌉 Handling the "Untaggable"

Not everything has a tag. How do you allocate $5,000 in monthly NAT Gateway fees?

| Cost Type | Example | Allocation Strategy |
| :--- | :--- | :--- |
| **Shared Infra** | NAT Gateways, VPCs | **Usage Ratio**: Split based on the data transfer of the services using it. |
| **Support Fees** | AWS Business Support | **Proportional**: Split based on the % of total spend per team. |
| **Platform** | K8s Control Plane | **Headcount/Capacity**: Split based on the number of nodes or pods per team. |

---

## 📂 Project Structure

Check out the `src/` directory for reference implementations:
- `tagging_policy.json`: A Service Control Policy (SCP) to enforce mandatory tags globally.
- `terraform_defaults.tf`: How to use `default_tags` in Terraform to automate high-level governance.

---

## 🎤 Interview Preparation

**1. What is the difference between Showback and Chargeback?**
> *Answer: Showback is for awareness; Chargeback is for actual budget deductions. Teams tend to optimize faster under a Chargeback model.*

**2. How do you allocate costs for a shared EKS cluster?**
> *Answer: By using tools like **KubeCost** to map pod-level resource requests (CPU/RAM) back to namespaces or labels.*

---

## 🚀 Take the Challenge
Open **[challenges.md](./challenges.md)** to design your first enterprise tagging policy.
