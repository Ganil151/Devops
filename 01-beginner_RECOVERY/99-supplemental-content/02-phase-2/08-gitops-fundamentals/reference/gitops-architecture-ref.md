# GitOps Architecture Reference

**Doc Version:** 1.0.0
**Role:** Cloud Architect
**Scope:** Controller Patterns & State Reconciliation

---

## 1. The Operator Pattern

GitOps is an implementation of the Kubernetes **Operator Pattern** applied to Deployment.

### The Loop
1.  **Observe**: Read the Current State (from the Cluster).
2.  **Diff**: Compare against Desired State (from Git).
3.  **Act**: If different, apply changes (`kubectl apply`) until matched.

**Properties:**
*   **Declarative**: You declare "I want 3 replicas", not "Add 1 replica".
*   **Convergent**: The system constantly tries to reach the desired state, even if manual interference breaks it.

---

## 2. Push vs. Pull Architecture

### A. Push (CI Driven)
*Traditional CD*
1.  CI Pipeline builds image.
2.  CI Pipeline runs `kubectl apply -f deployment.yaml`.
*   **Security Risk**: The CI Pipeline must hold "God Mode" credentials to the Cluster. If Jenkins is hacked, Production is compromised.

### B. Pull (GitOps Driven)
*ArgoCD / Flux*
1.  Agent sits *inside* the Cluster.
2.  Agent polls the Git Repo.
3.  Agent detects change and applies it to *itself*.
*   **Security Benefit**: No external credentials. The Cluster reaches *out* (Read Only) to Git.

---

## 3. The Drift Problem

**Configuration Drift** occurs when a human manually changes the cluster (`kubectl edit svc`).

*   **Self-Healing**: GitOps agents (ArgoCD) detect this immediately. "Live State != Git State".
*   **Auto-Sync**: If enabled, the Agent instantly reverts the manual change, restoring the state defined in Git.

---

## 4. Visualizing the Flow

```mermaid
graph LR
    subgraph "Trust Domain: CI"
    Git[Git Repo]
    end
    
    subgraph "Trust Domain: Cluster"
    Agent[GitOps Agent]
    App[Application]
    end
    
    Git -->|Pull (Read Only)| Agent
    Agent -->|Reconcile (Apply)| App
```
