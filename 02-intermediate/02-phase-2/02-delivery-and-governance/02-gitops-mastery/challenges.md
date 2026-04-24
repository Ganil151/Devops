# GitOps Mastery Challenges 🎡

Master the declarative deployment paradigm: "Git is the Single Source of Truth."

---

## 🏆 Challenge 01: The Reconciliation Loop
**Objective**: Synchronize your cluster state with a Git repository.

1.  **Requirement**: Connect an **ArgoCD** instance to a public Git repo containing K8s manifests.
2.  **Task**: Create an "Argo Application" (App-of-Apps pattern).
3.  **Discovery**: Observe the "Out of Sync" state when you manually delete a Service in the cluster using `kubectl`.
4.  **Goal**: Watch ArgoCD automatically "Re-sync" and recreate the service.

---

## 🏆 Challenge 02: Pull vs. Push Performance
**Objective**: Understand the architectural shift of GitOps.

1.  **Concept**: Traditional CI (Jenkins) "Pushes" code to the server. GitOps (ArgoCD) "Pulls" code from the repo.
2.  **Task**: Differentiate between the "Push" and "Pull" models in terms of security.
3.  **Analysis**: Which model requires opening fewer firewall ports into your production cluster? (Research: Cluster connectivity).

---

## 🏆 Challenge 03: The Sync Wave
**Objective**: Control the order of multi-service deployments.

1.  **Scenario**: A Web App that crashes if the Database isn't ready.
2.  **Requirement**: Research **ArgoCD Sync Waves**.
3.  **Task**: Annotate your DB deployment with `argocd.argoproj.io/sync-wave: "1"` and your Web deployment with `wave: "5"`.
4.  **Action**: Verify that Argo completes the DB sync before starting the Web sync.

---

## 📁 Solutions
ArgoCD Application manifests and Wave annotation examples are in the `Boilerplates/` directory.
