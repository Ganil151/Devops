# CI/CD Pipelines: The DevOps Heartbeat

Continuous Integration (CI) and Continuous Delivery (CD) are the core practices that allow teams to deliver high-quality software at speed. This module explores the tools and logic behind professional pipelines.

---

## 1. What is CI/CD?

- **Continuous Integration**: The practice of merging all developer working copies to a shared mainline several times a day. It focuses on automated testing to catch bugs early.
- **Continuous Delivery**: Ensures that the code is *always* in a deployable state.
- **Continuous Deployment**: Automatically deploys every change that passes the pipeline to production.

---

## 2. Core Modules

### 🔄 [Jenkins CI/CD](./Jenkins/README.md)
Master the "Automation Server" standard. Learn about Master-Agent architecture and Pipeline-as-Code.

### 🦊 [GitLab CI](./GitLab/README.md)
Integrated DevOps platform focus. Understanding `.gitlab-ci.yml` and runners.

### 🔍 [Quality Gates: SonarQube](./sonarQube/README.md)
Integrating static code analysis to ensure your code meets security and quality standards before deployment.

### 📚 [CICD Lessons & Patterns](./CICD_Lessons/README.md)
A collection of deep-dive lessons and common pipeline patterns used in the industry.

---

## 3. The 4 Stages of a Pipeline

1.  **Source**: Triggered by a Git push or Pull Request.
2.  **Build**: Compiling code and creating artifacts (e.g., Docker Images, JARs).
3.  **Test**: Running Unit, Integration, and Security tests.
4.  **Deploy**: Promoting the artifact to Staging, UAT, or Production.

---

## 4. Best Practices
- **Run in Containers**: Use ephemeral agents (Docker/K8s) for every build to ensure isolation.
- **Fail Fast**: Run the fastest tests first (Linting/Unit tests).
- **Security Gates**: Include secret scanning and SAST in every pipeline.
- **Artifact Versioning**: Every build should produce a unique, immutable artifact version.

---
**Next Level**: Automate your deployment reconciliation using [ArgoCD & GitOps](../../3-Advanced/01-GitOps/README.md).
