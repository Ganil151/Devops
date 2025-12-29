# GitOps: Interview Questions, Quiz & Scenarios

Enhance your GitOps expertise with these professional preparation materials.

---

## ❓ Interview Questions (Advanced)

1.  **Explain the difference between Push-based vs. Pull-based CI/CD.**
    *   *Answer*: Push-based (like Jenkins) triggers a job to push changes to the cluster. Pull-based (like ArgoCD) has an agent inside the cluster that watches a Git repo and "pulls" changes to reconcile the state. Pull-based is more secure and handles drift better.
2.  **What is "Configuration Drift" and how does GitOps solve it?**
    *   *Answer*: Drift occurs when manual changes are made to the cluster (e.g., `kubectl edit`). GitOps tools continuously compare the cluster state with Git and automatically revert manual changes to match the repo.
3.  **How do you handle secrets in a GitOps workflow?**
    *   *Answer*: Never store plain secrets in Git. Use tools like **Bitnami Sealed Secrets**, **HashiCorp Vault**, or **External Secrets Operator** to safely bridge secrets into the cluster.
4.  **Describe the role of an ArgoCD Application Controller.**
    *   *Answer*: It is the brain of ArgoCD that continuously monitors running applications and compares their live state against the desired state defined in the Git repository.

---

## 🧠 GitOps Knowledge Quiz (20+ Questions)

1.  **Which CNCF project is a popular GitOps tool?** (ArgoCD)
2.  **What is the "source of truth" in GitOps?** (The Git Repository)
3.  **True/False: GitOps requires a pull-based reconciliation loop.** (True)
4.  **What does 'Self-Healing' mean in a GitOps context?** (Automatic correction of manual cluster changes)
5.  **Which file format is most commonly used for GitOps manifests?** (YAML)
6.  **What is the purpose of the ArgoCD 'Sync' button?** (Manually trigger a reconciliation)
7.  **How do you define a 'Project' in ArgoCD?** (A logical grouping of applications with RBAC/Source constraints)
8.  **What is an ArgoCD 'Application'?** (A CRD that links a source repo to a destination cluster)
9.  **Which tool encrypts secrets so they can be safely stored in Git?** (Sealed Secrets)
10. **What is 'Progressive Delivery' in GitOps?** (Using Canary or Blue/Green deployments with tools like Argo Rollouts)
11. **What is the default sync policy in ArgoCD?** (Manual)
12. **Can GitOps be used for Infrastructure as Code?** (Yes, e.g., with Terraform Cloud/Enterprise or Atlantis)
13. **What is 'Manifest Generation'?** (Using Kustomize or Helm to produce raw YAML from templates)
14. **What is 'Pruning' in ArgoCD?** (Removing resources from the cluster that no longer exist in Git)
15. **What is a 'Sync Wave'?** (A way to order the application of manifests in a single sync)
16. **How does ArgoCD handle 'Out of Sync' status?** (By highlighting the diff between Git and Cluster)
17. **What is the 'Declarative Setup' of ArgoCD?** (An ArgoCD Application that manages other ArgoCD Applications)
18. **Which component provides the UI for ArgoCD?** (Argocd-server)
19. **What is 'Reconciliation Time'?** (The interval at which the controller checks for drift)
20. **Can ArgoCD manage multiple clusters?** (Yes, it can target remote clusters via Kubeconfig)
21. **What is 'Automated Pruning'?** (Automatically deleting resources that are removed from Git)

---

## 🏗️ Real-Life Scenarios

### Scenario 1: The "Manual Hack" Disaster
**Problem**: An engineer manually scaled a deployment to 10 replicas to handle a spike, but forgot to update Git.
**Solution**: ArgoCD detected the drift and scaled it back to 3 (the desired state in Git). The team learned to use Git-based scaling for persistence.

### Scenario 2: Secret Leak Prevention
**Problem**: A junior dev committed a database password in plain text to the GitOps repo.
**Solution**: The GitOps pipeline pre-commit hook (Gitleaks) blocked the push. The team implemented Sealed Secrets to ensure only encrypted blobs are ever in Git.

### Scenario 3: The Failed Canary
**Problem**: A new version of the app introduced a memory leak.
**Solution**: Using Argo Rollouts, the sync was paused at 10% traffic. Prometheus metrics showed the error spike, and the Rollout automatically aborted and reverted to the previous version without human intervention.
