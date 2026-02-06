# GitOps & Fleet Management

> **Declarative operations and multi-cluster deployment**

## Core Concept: Pull-Based Reconciliation
**[REFERENCE: Advanced GitOps Architecture](./reference/advanced-gitops-patterns-ref.md)**

GitOps shifts the paradigm from pushing changes to a "Continuous Reconciliation" model:
- **Desired vs. Actual**: The GitOps agent constantly ensures the cluster state matches the Git repository.
- **Pull-Based Security**: Eliminating the need for external systems to hold cluster credentials, reducing the attack surface.
- **Drift Detection**: Automatically identifying and reverting manual cluster modifications to maintain the source of truth in Git.

## Enterprise Governance: Fleet Orchestration
**[REFERENCE: Fleet Management \u0026 Scale](./reference/fleet-management-scale-ref.md)**

Scaling operations across hundreds of clusters without operational linear growth:
- **ApplicationSets**: Utilizing dynamic generators to automate application delivery across entire cluster fleets based on labels and properties.
- **Baseline Enforcement**: Ensuring every cluster in the fleet is automatically provisioned with core security, networking, and observability tools.
- **Hub-and-Spoke Governance**: Centralizing policy and control in a management cluster while delegating execution to the spokes.
- **OCI-Driven Supply Chain**: Extending the secure supply chain by using signed OCI artifacts as the source for Kubernetes manifests.

---

## 📚 Modules in This Part

1. **[01-GitOps-Advanced-Patterns](./01-gitops-advanced-patterns/)** - 01 GitOps Advanced Patterns
2. **[02-Fleet-Management-ApplicationSets](./02-fleet-management-applicationsets/)** - 02 Fleet Management ApplicationSets

---

## 🎯 Learning Path

These modules should be completed in the order shown above for optimal learning progression.

### Prerequisites

- Solid understanding of Kubernetes
- Experience with cloud platforms (AWS/GCP/Azure)
- Familiarity with GitOps principles

### Estimated Time

- Total: 16-24 hours
- Per module: ~8-12 hours

---

## 📂 Practical Code & Scripts

Accelerate your GitOps mastery with enterprise patterns:

- **[ArgoCD Deep Dive](./argocd/argo-deep-dive.md)**: Technical guide on installation and advanced patterns.
- **[Installation Scripts](./argocd/)**: Automated setup for ArgoCD on Kubernetes.

---

## 🔗 Related Parts

**Part of**: [Advanced Phase-2: Strategic Skills](../readme.md)
