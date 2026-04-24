# 🔄 Module 02: Push vs. Pull Architectures

> **"Security is not about building higher walls; it's about giving fewer people the keys."**

## 📚 Overview

How does the code get from Git to the Server? There are two main ways: **Pushing** it from a CI server, or letting the server **Pull** it from Git.

## 🎓 Learning Objectives

- ✅ Understand the **Push Model** (Jenkins style).
- ✅ Understand the **Pull Model** (ArgoCD style).
- ✅ Analyze the security benefits of removing `kubectl` access from CI.

---

## ⚔️ The Models

### 1. Push Model (Traditional)
The CI/CD pipeline (e.g., GitHub Actions) builds the app and then **runs a command** to deploy it to the cluster.
- **Risk**: The CI system needs "God Mode" (admin) credentials to the production cluster. If CI is hacked, Production is hacked.

### 2. Pull Model (GitOps)
An "Agent" running *inside* the cluster constantly watches the Git Repo. When it sees a change, it pulls the new config and applies it.
- **Benefit**: The cluster needs read-only access to Git. No external system has admin access to the cluster.

---

**Next Step**: Prove your skills in **[CHALLENGES.md](../../challenges.md)** 🚀
