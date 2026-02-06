# 🛡️ Part 4: The Safety Net (Governance & Security)

> **"Speed is irrelevant if you're driving in the wrong direction — or off a cliff. Governance is the steering wheel, not the brakes."**

Welcome to **The Safety Net**. In Advanced DevOps, you don't secure single servers; you secure **Platforms** and **Budgets**.

## 🛣️ The Curriculum

### [01-Security-Compliance](./01-security-compliance/)
**The Objective**: Move from "Security Gate" (Blocking) to "Guardrails" (Guiding).
*   **Key Concepts**: 
    *   **DevSecOps**: Integrating scanners (Trivy, Grype) into the pipeline.
    *   **Policy as Code**: Using OPA/Kyverno to prevent bad deployments automatically.
    *   **Supply Chain Security**: Signing images (Cosign) and generating SBOMs.

### [02-FinOps-Governance](./02-finops-governance/)
**The Objective**: Stop the bleeding. Cloud bills grow faster than revenue if unchecked.
*   **Key Concepts**:
    *   **Unit Economics**: Measuring "Cost per Transaction" not just "Total Cost".
    *   **Tagging Strategy**: If it's not tagged, it's deleted.
    *   **Spot Instances & Savings Plans**: Automated arbitrage of cloud resources.

---

## 🚀 The Difference: Junior vs. Senior

| Feature | Junior Approach | Principal approach |
|:---|:---|:---|
| **Security** | "I installed a firewall." | "I implemented Zero Trust mTLS architecture." |
| **Compliance** | "I check the boxes once a year." | "Compliance is continuous and automated via OPA." |
| **Cost** | "I ignored the bill until the CFO yelled." | "I engineered auto-scaling based on unit-cost metrics." |

---

## 🛠️ The Toolkit

*   **Open Policy Agent (OPA)**: General-purpose policy engine.
*   **Kyverno**: Kubernetes-native policy.
*   **Infracost**: Pull Request cost estimates.
*   **Falco**: Runtime security monitoring.

---
**Status**: ✅ Organized (2026-02-02)
