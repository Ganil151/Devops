# 🏗️ Jenkins CI/CD Pipelines

This directory contains enterprise-grade Jenkins pipeline blueprints and automation scripts.

---

## 📂 Directory Structure

### 🎯 [Blueprints Gallery](./blueprints/)

Production-ready pipeline templates for various deployment scenarios:

- **[Docker Compose](./blueprints/blueprint-docker-compose.groovy)** - Fast local/single-node deployments
- **[AWS EC2 + Docker](./blueprints/blueprint-aws-ec2-docker.groovy)** - Hybrid cloud deployments
- **[Blue/Green Deploy](./blueprints/blueprint-blue-green.groovy)** - Zero-downtime deployments
- **[Quality Gates & SAST](./blueprints/blueprint-quality-gates-sast.groovy)** - Security-first pipelines
- **[Enterprise K8s Full](./blueprints/blueprint-enterprise-k8s-full.groovy)** - Full-scale orchestration

👉 **[View Full Blueprint Documentation](./blueprints/readme.md)**

---

## 🚀 Quick Start

1. Choose the appropriate blueprint for your use case
2. Copy the `.groovy` file to your project's `Jenkinsfile`
3. Customize environment variables and credentials
4. Commit and trigger your pipeline

---

## 📚 Resources

- **[Setup Scripts](./jenkins-setup.sh)** - Automated Jenkins installation
- **[Assets](./assets/)** - Architecture diagrams and reference materials
- **[Resources](readme.md)** - Cheat sheets and guides
