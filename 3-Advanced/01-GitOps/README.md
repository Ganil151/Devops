# GitOps: The Ultimate Delivery Model

GitOps is a modern evolution of Continuous Delivery. It treats **Git as the single source of truth** for both infrastructure and applications. In this module, we move beyond "pushing" code to "reconciling" state.

---

## 🏗️ The Reconciler Architecture

In traditional CD, a pipeline (like Jenkins) "pushes" changes to a cluster. In GitOps, an agent runs **inside** the cluster (like ArgoCD) and pulls the desired state from Git.

- **The Git Repo**: Defines exactly what should be running (the "Desired State").
- **The Agent**: Constantly compares Git to the cluster (the "Actual State").
- **The Sync**: If they don't match, the agent automatically "reconciles" the cluster to match Git.

---

## 🛡️ Why GitOps is Essential for Enterprises

1. **Self-Healing Infrastructure**: If someone manually deletes a pod, ArgoCD will bring it back within seconds because Git says it should exist.
2. **Easy Rollbacks**: To revert a deployment, you simply `git revert` the last commit. The cluster will catch up instantly.
3. **Auditability**: Every change to the infrastructure is a Git commit. You have a perfect history of who changed what, when, and why.
4. **Enhanced Security**: You don't need to give your CI tool (Jenkins/GitHub) admin access to your cluster. The cluster pulls the configuration itself.

---

## 🛠️ Core Tool: ArgoCD

ArgoCD is the industry choice for GitOps on Kubernetes.
- **Application Controller**: Manages the lifecycle of multiple applications across multiple clusters.
- **Repo Server**: Parses your manifests (Helm, Kustomize, or plain YAML).
- **API Server**: Provides a powerful UI and CLI for drift detection and manual overrides.

---

## 💡 Best Practices
- **Never push to the cluster manually**: Disable `kubectl apply` for human users.
- **Separation of Concerns**: Keep your application code and your K8s manifests in separate repositories.
- **Automated Sync**: Enable "Prune" to remove deleted resources from the cluster automatically.

---
**Hands-on**: Explore the [Advanced Kubernetes Module](../03-Advanced-K8s/README.md) to see how GitOps manages complex stateful systems.
