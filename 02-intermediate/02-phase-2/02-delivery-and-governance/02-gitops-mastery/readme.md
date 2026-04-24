# 🟡 GitOps with ArgoCD (Intermediate)

## 📚 Overview

ArgoCD is a declarative, GitOps continuous delivery tool for Kubernetes. It monitors your Git repository for changes to your Kubernetes manifests and automatically applies those changes to your cluster.

## Core Concept: The Reconciliation Loop
**[REFERENCE: ArgoCD Architecture](./reference/argocd-architecture-ref.md)**

GitOps shifts the "Source of Truth" from the cluster to Git:
- **Declarative State**: We define *what* we want in Git, not *how* to get there.
- **Drift Detection**: ArgoCD continuously compares the "Desired State" (Git) with the "Live State" (Cluster).
- **Self-Healing**: Automatically reversing manual cluster edits to ensure Git remains the master record.

## Enterprise Governance: Scaling and Safety
**[REFERENCE: ArgoCD Architecture](./reference/argocd-architecture-ref.md)**

Managing production Kubernetes at scale requires rigorous standards:
- **App-of-Apps**: A recursive pattern for managing hundreds of applications through a single parent manifest.
- **Sync Policies**: Choosing between automated "Cruise Control" and manual "Human Gates" based on environment risk.
- **RBAC & Projects**: Restricting team access to specific namespaces and repositories.
- **SSO Integration**: Centralizing identity and avoiding local user accounts in the ArgoCD UI.

## 🎯 Learning Objectives

- ✅ Install ArgoCD using **Helm**.
- ✅ Connect a Git repository to ArgoCD.
- ✅ Implement **Sync Policies** (Manual vs. Automatic).
- ✅ Manage application life cycles via the ArgoUI and CLI.

---

## 🏗️ Visual: ArgoCD Sync Lifecycle

```mermaid
sequenceDiagram
    participant D as Developer
    participant G as Git Repository
    participant A as ArgoCD
    participant K as Kubernetes Cluster

    D->>G: git commit -m "Update scale to 3"
    D->>G: git push
    Note over A: Watches Git Repo
    A->>G: Fetch latest manifests
    A->>A: Compare Git vs Live State
    Note right of A: Drift Detected!
    A->>K: Apply Manifest (kubectl apply)
    K-->>A: Status: Synchronized
```

---

## 🚀 Hands-on: Deployment via Helm

1.  **Add Argo Repo**:
    ```bash
    helm repo add argo https://argoproj.github.io/argo-helm
    helm repo update
    ```
2.  **Install**:
    ```bash
    helm install argo-cd argo/argo-cd --namespace argocd --create-namespace
    ```
3.  **Access UI**:
    ```bash
    kubectl port-forward service/argo-cd-argocd-server -n argocd 8080:443
    ```

---
## 🏆 Professional Pattern: The "App-of-Apps"
For managing complex environments, use the **App-of-Apps** pattern. One ArgoCD Application manages a directory of other ArgoCD Applications, allowing you to bootstrap an entire cluster with a single Git command.

---
**Next Step**: [ArgoCD Setup](readme.md) 🚀
