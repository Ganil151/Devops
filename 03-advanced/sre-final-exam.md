# 🏆 The SRE Final Exam: Principal Solution Architect Certification

> **"Theory is when you know everything but nothing works. Practice is when everything works but nobody knows why. Chaos is when nothing works and nobody knows why."**

This exam is designed to validate your ability to design, operate, and optimize global-scale infrastructure. It is not a multiple-choice test; it is a series of **Architectural Scenarios** and **Technical Justifications**.

---

## 🏗️ Part 1: Global Architectural Design (The Blueprint)

**Scenario**: A Fintech application is expanding from `us-east-1` (AWS) to `westeurope` (Azure). They require 99.99% availability and must comply with GDPR (EU data cannot leave the EU).

1.  **Architecture**: Draw (or describe) the High-Level networking topology connecting these two clouds. Explain your choice between VPN Mesh and Dedicated Interconnect.
2.  **Identity**: How will you ensure an EKS pod in AWS can securely access an Azure SQL database without using static passwords?
3.  **Data Sovereignty**: How will you handle the database layer to ensure EU user data stays in Azure (EU) while maintaining a global "System of Record" for analytics?

---

## 🧪 Part 2: Chaos & Resilience (The "Friday Afternoon" Test)

**Scenario**: You are implementing a Chaos Experiment on your new Multi-Region EKS cluster.

1.  **Hypothesis**: Formulate a "Steady State" and a hypothesis for the total failure of a **Transit Gateway**.
2.  **Implementation**: Describe the specific AWS FIS Action or Gremlin Attack you would use to simulate this.
3.  **Blast Radius**: What is your "Emergency Stop" condition? Which CloudWatch Alarm would trigger the immediate halt of the experiment?

---

## 💰 Part 3: FinOps & Cost Engineering (The Unit Economics)

**Scenario**: The CFO complains that "Cloud costs are up 30%, but we only have 10% more customers."

1.  **The Audit**: You discover a massive EKS cluster with 18% CPU utilization. Propose a technical solution to automate the rightsizing of this cluster (Hint: Karpenter/Autoscaler).
2.  **Shift Left**: Write a sample `check_budget.sh` script or OPA policy logic that blocks a Terraform PR if it introduces a NAT Gateway without a justification tag.
3.  **Unit Economics**: Calculate the "Cost per Transaction" if your monthly bill is $50,000 and you processed 2 million transactions. If you switch to Spot Instances and save 60% on compute, what is the new Unit Cost?

---

## 🕵️ Part 4: Observability & Troubleshooting (The War Room)

**Scenario**: A "Service A -> Service B" call is failing with a `504 Gateway Timeout`. Both services are "Green" in their local dashboards.

1.  **Instrumentation**: Explain how you would use **OpenTelemetry Trace Context** to find which specific database query or sidecar proxy is causing the delay.
2.  **eBPF**: How would you use eBPF-based tools (like Cilium or Hubble) to prove the issue is a network drop (TCP Reset) rather than an application-level bug?
3.  **SLO/SLI**: Define a Service Level Objective (SLO) for this interaction. What is your "Error Budget" for a 30-day window if your target is 99.5%?

---

## 🏁 Submission Guidelines
For each part, provide a markdown document with:
- **The Rationale**: Why you chose X over Y.
- **The Trade-offs**: What are you sacrificing (Cost? Latency? Supportability?)
- **The Code**: Provide the Terraform snippets, OPA policies, or FIS templates that back up your design.

---
**Status**: 🎓 Exam Ready for Takers
**Pass Requirement**: 75% score across all architectural pillars.
