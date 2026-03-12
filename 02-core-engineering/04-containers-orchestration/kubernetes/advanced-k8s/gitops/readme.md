# Advanced Level: GitOps

GitOps is a set of practices to manage infrastructure and application configurations using Git, an open-source version control system. It is the modern standard for Continuous Delivery (CD) in Kubernetes.

## 🎯 Learning Objectives
- Understand the **Pull vs Push** model.
- Introduction to **ArgoCD** and **Flux**.
- Managing cluster state via Git.

## 1. The Core Principles
1. **Declarative**: The entire system is described declaratively (YAML).
2. **Versioned**: The canonical desired system state is versioned in Git.
3. **Automated**: Approved changes can be automatically applied to the system.
4. **Resilient**: Software agents ensure correctness and alert on divergence.

## 2. Pull vs Push
- **Push (CI/CD Pipelines)**: Usually Jenkins/GitLab CI runs `kubectl apply`. This requires giving the CI tool admin access to your cluster (Security Risk).
- **Pull (GitOps Controller)**: An agent (ArgoCD) runs *inside* the cluster and pulls changes from Git. It only needs read access to Git.

## 3. ArgoCD Overview
ArgoCD is the most popular GitOps tool.

### Concepts
- **Application**: A CRD that maps a Git Repo/Path to a Cluster/Namespace.
- **Sync**: The process of making the live cluster match the Git state.
- **Health**: Weather the application is running reliably.

### Workflow
1. Developer pushes code to `main` branch.
2. CI builds Docker image and pushes to Registry.
3. CI (or Dev) updates the deployment YAML in the **Config Repo** with the new image tag.
4. ArgoCD detects the change in Git.
5. ArgoCD syncs the cluster to match Git.

## 4. Why Use GitOps?
- **Audit Log**: Git history is your audit log. who changed what and when.
- **Revert**: `git revert` is your rollback mechanism.
- **Drift Detection**: If someone manually changes a value in the cluster (via `kubectl`), ArgoCD detects the drift and warns (or auto-fixes) it.

[Back to Advanced Index](../readme.md)
