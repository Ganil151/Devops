# 📐 Part 1: The Blueprint (Architecture & Scale)

> **"A Junior Engineer writes code. A Principal Engineer writes the strategy that allows 100 Engineers to write code without crashing the system."**

Welcome to **The Blueprint**. This is where we stop thinking about "Servers" and start thinking about "Systems."

## 🛣️ The Curriculum

### [01-Cloud-Architecture](./01-cloud-architecture/)
**The Objective**: Apply the AWS Well-Architected Framework to everything.
*   **Key Concepts**: 
    *   **The 6 Pillars**: Operational Excellence, Security, Reliability, Performance, Cost, Sustainability.
    *   **Trade-offs**: CAP Theorem, Eventual Consistency, and picking the right database.
    *   **Hybrid Cloud**: Designing for connectivity between On-Prem and AWS (Direct Connect, VPN).

### [02-Platform-Engineering](./02-platform-engineering/)
**The Objective**: Stop being the bottleneck. Build an Internal Developer Platform (IDP).
*   **Key Concepts**:
    *   **Product Thinking**: Your users are the developers.
    *   **Self-Service**: If they have to open a Jira ticket to get a database, you failed.
    *   **Backstage**: Building a developer portal.

### [03-Multi-Cluster](./03-multi-cluster/)
**The Objective**: One Kubernetes cluster is a pet. Ten clusters are cattle.
*   **Key Concepts**:
    *   **Cluster API**: Provisioning clusters using K8s manifests.
    *   **Federation**: Managing apps across regions (Karmada/KubeFed).
    *   **Tenancy**: Hard extraction (Clusters) vs Soft extraction (Namespaces).

---

## 🚀 The Difference: Junior vs. Senior

| Feature | Junior Approach | Principal Approach |
|:---|:---|:---|
| **Request** | "I need a DB." -> "Okay, I'll build it." | "I need a DB." -> "Go to the portal and click Create." |
| **Scale** | "We have a big k8s cluster." | "We have ephemeral clusters per team." |
| **Outage** | "AWS is down!" | "Our multi-region active-active failover just triggered." |

---

## 🛠️ The Toolkit

*   **Backstage**: The IDP frontend.
*   **Crossplane / Cluster API**: The IDP backend.
*   **Karamada**: The Federation engine.
*   **Draw.io**: The Architect's IDE.

---
**Status**: ✅ Organized (2026-02-02)
