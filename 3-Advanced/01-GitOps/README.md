# GitOps: Declarative Infrastructure & Applications

GitOps is a modern way to do Continuous Delivery. It uses Git as the "Single Source of Truth" for your infrastructure and applications, ensuring that what you see in your repo is exactly what is running in your cluster.

---

## 1. The Core Idea: Reconciliation

In traditional CD, you "push" code to a server. In GitOps, a "controller" inside your cluster "pulls" the configuration from Git and constantly checks:
- **Desired State**: What is defined in Git (e.g., "I want 3 replicas of my app").
- **Actual State**: What is currently running in the cluster (e.g., "There are only 2 replicas running").
- **Reconciliation**: If they don't match, the controller automatically fixes it.

---

## 2. Why GitOps?

- **Zero Manual Changes**: No one should run `kubectl apply` manually. Everything goes through Git.
- **Drift Detection**: If someone manually changes a setting in the cluster, GitOps will automatically revert it.
- **Audit Trail**: Every change is a Git commit, so you know who changed what and when.
- **Fast Recovery**: If your cluster dies, you just point your GitOps tool at the Git repo and your entire environment is rebuilt in minutes.

---

## 3. Core Tooling

- **ArgoCD**: The industry standard for GitOps on Kubernetes. It provides a powerful UI and advanced sync policies.
- **FluxCD**: A lightweight, highly secure GitOps controller that is part of the CNCF.

---

## 4. Best Practices
1. **Separate Repos**: Keep your application code in one repository and your infrastructure/manifests in another.
2. **Pull Requests Only**: All changes to production must be approved via a PR.
3. **Automated Sync**: Enable "Self-Heal" to prevent manual drift.

---
**Hands-on**: Explore the [ArgoCD Documentation](./ArgoCD/README.md) to set up your first GitOps synchronization.
