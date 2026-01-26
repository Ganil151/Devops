# 🚀 Root Quick Reference: The DevOps Master Logic
*Version 3.1 - Enhanced Orchestration Edition*

This file serves as the core entry point for the high-level logic across all tiers. Use this to quickly navigate frequent commands, architecture patterns, and the "Trinity" orchestration suite.

---

## 🛠️ The "Trinity" Orchestration Suite
These master scripts are designed for cross-platform system management.

| Goal | Language | Location | Primary Command |
| :--- | :--- | :--- | :--- |
| **Health Audit** | Python | `./2-Intermediate/01-Phase-1/03-Runbooks-Procedures/scripts/` | `python resource_monitor.py` |
| **Hybrid Check** | PowerShell | `./2-Intermediate/01-Phase-1/03-Runbooks-Procedures/scripts/` | `.\Invoke-HybridHealthCheck.ps1` |
| **Node Harden** | Bash | `./2-Intermediate/01-Phase-1/02-Linux/scripts/` | `sudo ./harden-linux-node.sh` |
| **K8s Audit** | PowerShell | `./3-Advanced/01-Phase-1/04-Container-Orchestration/scripts/` | `.\Invoke-K8sClusterAudit.ps1` |
| **Cloud Artifact** | PowerShell | `./2-Intermediate/02-Phase-2/01-Infrastructure-Automation/scripts/` | `.\Sync-S3CloudBackup.ps1` |

---

## 🗺️ Navigation Index
For detailed module break-downs, refer to the local `Quick_Reference.md` in each tier:

- 🌱 **[Beginner Fundamentals](./1-Beginner/Quick_Reference.md)**: Linux, Networking, Cloud Intro.
- ⚙️ **[Intermediate Automation](./2-Intermediate/Quick_Reference.md)**: IaC, Docker, CI/CD.
- 🏛️ **[Advanced Enterprise](./3-Advanced/Quick_Reference.md)**: Service Mesh, GitOps, Kubernetes.
- 👔 **[Professional Career](./4-Professional-Development/Quick_Reference.md)**: Projects, Portfolios, Resumes.

---

## 📊 Core Command Matrix (Essential DevOps)

### 📦 Infrastructure as Code (Terraform)
```bash
terraform init          # Initialize workspace
terraform plan          # Preview infrastructure changes
terraform apply         # Deploy to provider (AWS/Azure/GCP)
```

### 🐋 Containers & Orchestration
```bash
docker build -t app:1.0 .  # Build local image
docker-compose up -d        # Deploy local stack
kubectl get pods -A         # View all running pods
```

### 🐍 Automation Logic (Python)
```bash
python -m venv .venv        # Create isolation
pip install -r reqs.txt     # Install dependencies
python script.py            # Execute automation
```

---

## 🛡️ Repository Standards
1.  **Atomicity**: Every functional module MUST have its own `Quick_Reference.md`.
2.  **No Rot**: Use the [Link Scanner](./00-Resources/01-Scripts-Code/Maintenance/repository_audit.py) to verify internal links.
3.  **Hierarchy**: Follow the `Beginner -> Intermediate -> Advanced` flow for learning.

---
*"Infrastructure is code. Knowledge is scale."*
