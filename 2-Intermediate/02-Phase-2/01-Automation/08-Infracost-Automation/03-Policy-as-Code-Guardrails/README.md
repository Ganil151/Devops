# Policy as Code Guardrails

Cost estimation is a suggestion. **Guardrails** are the laws. By combining Infracost with Policy-as-Code (like OPA/Rego), you can block expensive deployments before they happen.

## 📚 Module Structure
- **[Boilerplates](./Boilerplates/)**: `cost_policy.rego` (Open Policy Agent logic).
- **[CHALLENGES](./CHALLENGES.md)**: Blocking expensive instances and regions.

---

## 🏗️ The "Budget Gatekeeper"
You can define policies that check the `infracost.json` output for violations.

| Rule | Action | Rationale |
| :--- | :--- | :--- |
| **No `m5d.24xlarge`** | FAIL | Prevent accidental use of extreme performance instances. |
| **Max Diff > $1000** | HOLD | Require CTO approval for large architecture changes. |
| **No Public IPs** | WARN | IPv4 addresses now cost money and add security risk. |

---

## 🏗️ Example Policy (REGO)
```rego
package infracost

# Deny if total monthly cost increase is more than $500
deny[msg] {
    diff := input.totalMonthlyCost
    to_number(diff) > 500
    msg := sprintf("Cost increase of $%v exceeds the $500 limit", [diff])
}
```

---

## 📖 Real-World Story: The "Bitcoin Mine" Averted
A developer's account was compromised. The attacker tried to launch 50 GPU instances in an unmonitored region (`ap-southeast-1`).
**Policy Guardrail**: The CI system ran Infracost + OPA.
**Result**: The policy detected a +$20,000/month increase and a "Forbidden Instance Type" rule violation.
**Outcome**: The deployment was automatically blocked, and security was alerted.

---

## ❓ Interview Questions
1. **What is OPA (Open Policy Agent)?**
   - *Answer*: A domain-agnostic policy engine that uses the 'Rego' language to make decisions based on JSON input.
2. **Why separate Policy from the CI Workflow?**
   - *Answer*: This follows the "Separation of Concerns" principle. Finance can update the `rego` policy file without needing to understand the GitHub Action YAML.

---

[⬅️ Back to Infracost Index](../README.md)
