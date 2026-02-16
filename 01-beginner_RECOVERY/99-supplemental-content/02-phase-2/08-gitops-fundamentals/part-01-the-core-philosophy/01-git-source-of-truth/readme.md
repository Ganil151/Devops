# 📜 Module 01: Git as Source of Truth

> **"Declarative configuration is the contract. Git is the vault where we keep the contract."**

## 📚 Overview

The core tenet of GitOps is simple: **Git is the Source of Truth**. This means that the entire state of your infrastructure (VMs, Load Balancers, Kubernetes Pods) should be described in files stored in a Git repository.

## 🎓 Learning Objectives

- ✅ **Imperative vs. Declarative**: Understanding the difference between "How to do it" (Script) and "What to have" (YAML).
- ✅ **Version Control**: Every change is a commit. Every revert is a `git revert`.
- ✅ **Audit Trail**: `git log` tells you exactly who changed what and when.

---

## 🏗️ Imperative vs. Declarative

### Imperative (The Old Way)
"Login to the server, install Nginx, and start it."
```bash
ssh user@server
apt-get install nginx
systemctl start nginx
```
*Problem*: If the server crashes, you have to remember exactly what commands you ran.

### Declarative (The GitOps Way)
"Here is a file that says Nginx should be running. Make it happen."
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-server
spec:
  replicas: 1
```
*Benefit*: If the server crashes, you just re-apply this file.

---

**Next Step**: Explore models in **[Module 02: Push vs. Pull](../../part-02-architecture-models/02-push-vs-pull-basics/readme.md)** 🚀
