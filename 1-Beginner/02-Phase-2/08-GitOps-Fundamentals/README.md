# 📈 GitOps Fundamentals (Beginner)

> **"Your Git repository is the single source of truth for your desired infrastructure state."**

## 📚 Overview

GitOps is an operational framework that takes DevOps best practices used for application development, such as version control, collaboration, compliance, and CI/CD, and applies them to infrastructure automation.

## 🎯 Learning Objectives

- ✅ Understand the core principle: **Git as Source of Truth**.
- ✅ Differentiate between **CI** (Continuous Integration) and **CD** (Continuous Deployment/Delivery).
- ✅ Learn the difference between **Push-based** and **Pull-based** deployments.
- ✅ Understand how "Drift" is detected and remediated.

## 🗺️ Module Structure

1.  **[🟢 01-Git-Source-of-Truth](./01-Git-Source-of-Truth/)**
    - Declarative vs. Imperative configurations.
    - Version controlling your YAMLs.
2.  **[🟢 02-Push-vs-Pull-Basics](./02-Push-vs-Pull-Basics/)**
    - The "Push" model (Jenkins, GitHub Actions).
    - The "Pull" model (ArgoCD, FluxCD).
    - Why Pull-based is more secure.

---

## 🏗️ Visual: Push vs. Pull Architectures

```mermaid
graph TD
    subgraph Push_Based
    A[Dev Commit] --> B[CI Runner]
    B -- SSH/API Key --> C[Cluster]
    end
    
    subgraph Pull_Based
    D[Dev Commit] --> E[Git Repo]
    F[GitOps Agent] -- Watch --> E
    F -- Local Sync --> G[Cluster]
    end
    
    style C fill:#00b894,color:#fff
    style G fill:#00b894,color:#fff
```

## 📋 Professional Pattern: Declarative Everything
Never use `kubectl edit` or `ansible-playbook` manually on production nodes. If you want to change the system, change the code in Git, and let the system reconcile itself.

---
**Next Step**: Start with [Git Source of Truth](./01-Git-Source-of-Truth/) 🚀
