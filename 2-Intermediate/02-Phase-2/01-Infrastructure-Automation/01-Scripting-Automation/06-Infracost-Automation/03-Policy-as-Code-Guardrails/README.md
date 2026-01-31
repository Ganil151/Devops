# 🛡️ Policy-as-Code: Automated Cost Guardrails

> **"Cost visibility is a suggestion. Cost guardrails are the law. In a high-velocity engineering organization, you don't wait for permission; you build a system that enforces the boundaries for you."**

Welcome to the **Policy-as-Code (PaC) Guardrails** module. While Infracost provides visibility, Guardrails provide **Enforcement**. By combining Infracost's JSON output with policy engines like **Open Policy Agent (OPA)** or custom Python logic, you can implement automated financial governance that blocks expensive or non-compliant infrastructure changes before they reach production.

---

## 🏗️ The Guardrail Lifecycle

Financial governance is a **Pre-Merge Enforcement** step. We move from "Manual Reviews" to **Automated Gatekeeping.**

```mermaid
graph TD
    A[Output: Infracost JSON] --> B{Policy Engine: OPA / Rego}
    B -- Rule 1 --> C[Total Change < Target Budget?]
    B -- Rule 2 --> D[Infrastructure Best Practices?]
    B -- Rule 3 --> E[Allowed Instance Types/Regions?]
    
    C & D & E -- "All Pass" --> F[CI: Success / Pass]
    C | D | E -- "Violation" --> G[🚨 Block CI: Fail Build]
    
    style B fill:#ee0000,color:#fff
    style G fill:#fee2e2,stroke:#dc2626
    style F fill:#f0fdf4,stroke:#15803d
```

---

## 🎭 Real-World DevOps Scenarios

### 🧱 Scenario: The "Crypto-Mining" Prevention
**The Incident:** A developer's GitHub account was compromised. The attacker attempted to merge a Pull Request that added 50 `p3.16xlarge` (GPU) instances in an unmonitored region to start a crypto-mining operation.
**The Failure:** The PR looked like a standard "infrastructure scaling" update to an untrained eye. If merged, it would have cost **$45,000/week.**
**The Fix:** A **Policy-as-Code Guardrail**. The OPA engine analyzed the Infracost output and detected two major violations: 1. A monthly cost increase exceeding $1,000, and 2. The use of "Forbidden Instance Types" (GPU instances) in a non-AI project.
**The Result:** The PR was automatically blocked. The security team was alerted by the CI failure, the account was locked down, and the $45k bill was averted before a single credit card was charged.

---

## 💻 DevOps Logic Snippets: "The Financial Law"

Standardize your financial rules using the Rego language for maximum portability.

```rego
# 🚀 Standard: cost_policy.rego
package infracost

# 1. 🛡️ Guardrail: Deny if cost increase exceeds monthly budget
deny[msg] {
    diff := to_number(input.diffTotalMonthlyCost)
    diff > 500
    msg := sprintf("🚨 BUDGET VIOLATION: Cost increase of $%v exceeds the $500 monthly limit.", [diff])
}

# 2. 🛡️ Guardrail: Prevent use of "Overkill" instances in Dev
deny[msg] {
    # Cross-reference with metadata tags
    input.projects[_].metadata.environment == "development"
    instance := input.projects[_].breakdown.resources[_]
    contains(instance.name, "metal")
    msg := sprintf("🚨 COMPLIANCE ERROR: Bare metal instance (%v) is forbidden in Development environments.", [instance.name])
}
```

---

## 🎙️ Interview Preparation (Guardrails & Governance)

1.  **"What is Open Policy Agent (OPA) and how does it relate to Infracost?"**
    *   *Answer:* OPA is a general-purpose policy engine. Infracost outputs its cost analysis in JSON format, which is the native input for OPA. This allows engineers to write "Rego" policies that evaluate the cost data and decide whether a Pull Request should be allowed or blocked.
2.  **"Why use Policy-as-Code instead of just letting the Finance team review Every PR?"**
    *   *Answer:* Scale and Speed. A manual review process creates a bottleneck and wastes expensive human time on trivial checks. PaC allows 99% of "safe" changes to pass instantly while automatically flagging only the 1% of "risky" changes that actually need a human eye.
3.  **"What is the difference between a 'Warning' guardrail and a 'Block' guardrail?"**
    *   *Answer:* A Warning (Soft Guardrail) posts a message to the PR but allows the CI build to pass—useful for awareness. A Block (Hard Guardrail) fails the CI step and prevents the merge—used for critical budget violations or security risks.
4.  **"How can you implement 'Department-Specific' budget limits using Infracost?"**
    *   *Answer:* By combining Terraform tagging with Infracost. If every resource has a `Department` tag, the Infracost JSON will include that data. Your OPA policy can then apply different budget limits (e.g., $5,000 for Marketing vs $10,000 for Platform) based on that tag.
5.  **"Explain the 'Separation of Duties' benefit of using specialized policy files."**
    *   *Answer:* By storing policies in separate `.rego` files, the Finance or FinOps team can manage the "Financial Rules" independently of the "Deployment Scripts." The platform engineer manages the pipeline (How it runs), while the FinOps lead manages the policy (What is allowed).

---

## 🧠 Knowledge Check

1.  **Which language is primarily used to write policies for Open Policy Agent (OPA)?**
    *   [ ] Python
    *   [x] Rego
    *   [ ] YAML
2.  **What is a 'Hard Guardrail'?**
    *   [ ] A physical fence around a data center.
    *   [x] A policy that automatically fails the CI build and prevents a merge.
    *   [ ] A suggestion to the developer to save money.
3.  **True or False: Policy-as-Code allows you to enforce rules based on individual resource types (e.g., 'No bare metal').**
    *   [x] True
    *   [ ] False
4.  **What data format must Infracost provide for OPA to analyze it?**
    *   [ ] CSV
    *   [ ] Markdown
    *   [x] JSON
5.  **Which keyword is used in Rego to define a rule that causes a failure?**
    *   [ ] `fail`
    *   [ ] `stop`
    *   [x] `deny`

---

[⬅️ Back to Infracost Index](../README.md)
