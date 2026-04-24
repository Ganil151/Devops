# 🛡️ Policy-as-Code: Automated Cost Guardrails

> **"Cost visibility is a suggestion. Cost guardrails are the law. In a high-velocity engineering organization, you don't wait for permission; you build a system that enforces the boundaries for you."**

Welcome to the **Policy-as-Code (PaC) Guardrails** module. Guardrails provide **Enforcement**. By combining Cost Data (Infracost) with a Policy Engine (OPA or Python), you can block expensive infrastructure changes *before* they reach production.

**Why This Matters for Junior DevOps Engineers:**
- 🛑 **Prevention**: Stopping a $45,000/week mistake.
- ⚡ **Autonomy**: Developers can deploy freely *as long as* they stay within the guardrails.
- ⚖️ **Compliance**: Enforcing rules like "All S3 buckets must have a `CostCenter` tag".

---

## 📚 Table of Contents

1. [Architecture: The Policy Engine](#-architecture-the-policy-engine)
2. [Option A: OPA (Rego)](#-option-a-opa-rego)
3. [Option B: Python Guardrails](#-option-b-python-guardrails)
4. [Real-World DevOps Scenarios](#-real-world-devops-scenarios)
5. [Common Pitfalls & Solutions](#-common-pitfalls--solutions)
6. [Hands-On Exercises](#-hands-on-exercises)
7. [Interview Preparation](#-interview-preparation)

---

## 🏗️ Architecture: The Policy Engine

Financial governance is a **Gatekeeper**.

```mermaid
graph TD
    A[Input: Infracost JSON] --> B{Policy Engine}
    B -- Rules File --> C[Validation Logic]
    C --> D{Compliance Check}
    D -- Pass --> E[Build Continues ✅]
    D -- Fail --> F[Block PR ❌]
    F -- Feedback --> G[Comment: "Budget Exceeded"]
    
    style A fill:#e0f2fe,stroke:#0369a1
    style F fill:#fee2e2,stroke:#dc2626
    style E fill:#f0fdf4,stroke:#15803d
```

### 🔍 Concept Breakdown
1.  **Input**: The data (Cost estimate).
2.  **Policy**: The rules (e.g., "Max $500 delta").
3.  **Engine**: The tool that applies rules to data (OPA or Python).

---

## 🏛️ Option A: OPA (Open Policy Agent)

OPA is the industry standard for cloud governance. It uses a language called **Rego**.

### The Rule (`policy.rego`)
```rego
package infracost

# Deny if cost increase > $500
deny[msg] {
    # Extract the total monthly increase
    diff := to_number(input.diffTotalMonthlyCost)
    
    # Logic
    diff > 500
    
    # Feedback Message
    msg := sprintf("🚨 Budget Audit Failed: Cost increase of $%v exceeds limit ($500)", [diff])
}

# Deny if using high-cost GPU instances in 'dev'
deny[msg] {
    tags := input.projects[_].metadata.tags
    resource := input.projects[_].breakdown.resources[_]
    
    tags.Environment == "dev"
    contains(resource.name, "p3.2xlarge")
    
    msg := "🚨 GPU instances are not allowed in Dev environment"
}
```

### Execution
```bash
infracost breakdown --path . --format json > cost.json
opa eval --input cost.json --data policy.rego "data.infracost.deny"
```

---

## 🐍 Option B: Python Guardrails

If Rego is too complex, Python works perfectly well for simple logic.

### The Script (`guardrail.py`)
```python
import json
import sys

def check_budget(file_path):
    with open(file_path) as f:
        data = json.load(f)
        
    diff = float(data.get('diffTotalMonthlyCost', 0))
    
    # Limit: $1000
    if diff > 1000:
        print(f"❌ BLOCKED: +${diff}/mo exceeds $1000 limit.")
        sys.exit(1) # Fails the pipeline
        
    print(f"✅ PASSED: +${diff}/mo is within budget.")

if __name__ == "__main__":
    check_budget("infracost.json")
```

---

## 🎭 Real-World DevOps Scenarios

### 🛡️ Scenario 1: The "Crypto-Mining" Prevention

**The Incident:** An attacker compromised a wrapper script and added 50 `p3.16xlarge` instances to mine crypto.
**The Fix:** A Guardrail policy that **Blocks** any PR adding > $10,000/mo or using GPU instances.
**The Result:** The PR was blocked instantly. The security team was alerted by the build failure.

### 🔥 Scenario 2: The "Missing Tag" Cleanup

**The Incident:** 30% of the AWS bill was "Untagged", making it impossible to chargeback to teams.
**The Fix:** A Policy rule:
> `deny` if `resource.tags.CostCenter` is missing.
**Result:** Developers were forced to add tags *before* they could merge. Cost attribution reached 100%.

### ☁️ Scenario 3: The "Manager Bypass"

**The Challenge:** Sometimes you *need* to spend $2,000 for a valid project. The guardrail blocks it.
**The Solution:** Exceptional Approval.
1. Guardrail fails.
2. Dev adds label `budget-approved` to PR.
3. Policy checks for label: `not input.pr.labels["budget-approved"]`.
4. If label exists, `deny` is skipped.

---

## ⚠️ Common Pitfalls

### Pitfall 1: Hard Blocking Everything
**Mistake**: Blocking PRs for a $0.01 increase.
**Result**: Developers hate the tool and disable it.
**Fix**: Set reasonable thresholds (e.g., < $50 is auto-approved).

### Pitfall 2: Opaque Errors
**Mistake**: Bot says "Failed".
**Fix**: Bot must say "Failed because cost (+$500) > limit ($100). Please break up the PR."

---

## 🎯 Hands-On Exercises

### Exercise 1: Python Guardrail
**Objective**: Block expensive changes.
**Task**:
1. Run `mid-range.tf` (Cost $50).
2. Write a Python script that errors if cost > $10.
3. Verify `sys.exit(1)` triggers.

### Exercise 2: OPA Rego (Advanced)
**Objective**: Deny missing tags.
**Task**:
1. Write a simple Rego rule to check if `tags` is empty.
2. Run it against a JSON output.

---

## 🎙️ Interview Preparation

### Foundation Questions

**1. "What is Policy-as-Code?"**
- **Answer**: Writing governance rules (e.g., "Max Cost", "Security Group Config") in code (Rego/Python) and enforcing them automatically in the CI pipeline.

**2. "Why use OPA over Python?"**
- **Answer**: OPA is designed for decoupling policy from code. It can be updated dynamically without redeploying the app. Python is easier to start with but hard to scale across 100 heterogeneous repositories.

### Advanced Scenario Questions

**3. "How do you implement a Soft Guardrail vs Hard Guardrail?"**
- **Answer**:
    - **Hard**: Fails the build (`exit 1`). Blocks Merge.
    - **Soft**: Posts a Warning Comment. Allows Merge. Used for "Best Practices".

---

## 🧠 Knowledge Check

**1. Which OPA keyword generates a failure?**
- [ ] `allow`
- [x] `deny`
- [ ] `warn`

**2. Where does the Guardrail strictly sit?**
- [ ] After Deployment
- [x] In the Pull Request (Pre-Merge)
- [ ] In the IDE

**3. What is the standard input format for OPA?**
- [ ] YAML
- [ ] XML
- [x] JSON

---

## 🎓 Self-Assessment Checklist

Before moving to the next module, ensure you can:
- [ ] Write a Python script to parse `infracost.json`.
- [ ] Implement a `sys.exit(1)` block condition.
- [ ] Explain the benefit of tagging enforcement.
- [ ] Differentiate between Soft and Hard guardrails.

**Score yourself**: 5+/5 = Ready to advance | <5 = Review exercises

[⬅️ Back to GitHub Actions](../02-github-actions-integration/readme.md)
