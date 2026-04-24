# 🏗️ Jenkins Blueprint Master Gallery

This directory serves as the centralized "Source of Truth" for DevOps pipeline patterns. Instead of maintaining fragmented `Jenkinsfile` assets across every project, use these blueprints as templates.

---

## 🗺️ Blueprint Index

| Blueprint Name | Complexity | Primary Tools | Use Case |
| :--- | :--- | :--- | :--- |
| [Docker Compose](./blueprint-docker-compose.groovy) | 🌱 Beginner | Docker, yq, Health Checks | Fast local or single-node environments. |
| [AWS EC2 + Docker](./blueprint-aws-ec2-docker.groovy) | ⚙️ Intermediate | AWS CLI, SSH, Boto3 logic | Hybrid cloud deployments to dedicated instances. |
| [Blue/Green Deploy](./blueprint-blue-green.groovy) | ⚙️ Intermediate | Docker, SSH, Shell scripts | High-availability deployments with zero downtime. |
| [Quality Gates & Scan](./blueprint-quality-gates-sast.groovy) | ⚙️ Intermediate | SonarQube, Trivy, GitOps | Security-first pipelines with automated gates. |
| [Enterprise K8s Full](./blueprint-enterprise-k8s-full.groovy) | 🏛️ Advanced | K8s, Ansible, AWS, Terraform | Massive scale, multi-tool orchestration (Full Lifecycle). |

---

## 🏛️ The Core Concept

Blueprints are **modularized** pipeline scripts. They decouple the *how* of deployment from the *what*. By using these patterns, you ensure that every project in your organization follows the same security, quality, and logging standards.

## 🚀 The "Why" for DevOps

- **Deduplication**: Fix a bug in a deployment script once, and it benefits everyone.
- **Onboarding**: New developers don't need to learn Jenkins DSL from scratch; they just copy the appropriate blueprint.
- **Auditability**: Security teams can audit 5 master blueprints instead of 500 individual repo files.

### 📈 Visual Marker: Pipeline Standardization

<div align="center">
  <img src="https://img.shields.io/badge/Strategy-Standardize%20&%20Scale-brightgreen?style=for-the-badge&logo=jenkins" alt="Pipeline Standardization Tag">
</div>

---

## ❓ Top 5 Interview Questions

1. **Explain the difference between Declarative and Scripted pipelines.**
   - *Answer*: Declarative (standard) uses structured blocks like `stages` and `steps` for readability. Scripted uses Groovy code for complex logic flexibility.
2. **How do you handle credentials safely in a Jenkinsfile?**
   - *Answer*: Use the `withCredentials` block or the `credentials()` helper to map IDs from the Jenkins Credentials Store to environment variables.
3. **What is a "Jenkins Shared Library"?**
   - *Answer*: A collection of Groovy scripts stored in an external repo that allows you to reuse code blocks across multiple Jenkinsfiles.
4. **How would you implement a rollback in Jenkins if a health check fails?**
   - *Answer*: Use a `post { failure { ... } }` block or a conditional `sh` script that executes an "undo" command (e.g., `docker compose down` or `kubectl rollout undo`).
5. **Why use parameters in a Jenkinsfile?**
   - *Answer*: It allows the same pipeline to be dynamic, targeting different nodes, branches, or environments (Dev/Prod) without modifying the code.
