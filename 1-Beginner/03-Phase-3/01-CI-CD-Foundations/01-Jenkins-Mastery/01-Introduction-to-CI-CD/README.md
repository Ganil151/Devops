# Introduction to CI/CD
*The Foundation of Modern Software Delivery*

In modern DevOps, **CI/CD** (Continuous Integration and Continuous Deployment/Delivery) is the engine that drives high-velocity releases. It automates the process of merging code, building artifacts, and deploying to production.

---

## 🏗️ Core Concepts

### 1. Continuous Integration (CI)
The practice of merging developer code into a shared repository several times a day. Each merge triggers an automated build and test sequence.
*   **Goal**: Detect bugs early and ensure the "main" branch is always buildable.

### 2. Continuous Delivery (CD)
Extends CI by automatically deploying all code changes to a testing or staging environment after the build stage.
*   **Goal**: Ensure that code is *always ready* for release at any time.

### 3. Continuous Deployment
The final evolution. Every change that passes all stages of your production pipeline is released to your customers automatically.
*   **Goal**: Zero-manual intervention from code push to production.

---

## ⚖️ Tool Comparison: Jenkins vs. The World

| Feature | Jenkins | GitHub Actions | GitLab CI |
| :--- | :--- | :--- | :--- |
| **Type** | Self-Managed (Server) | SaaS (Cloud-Native) | Integrated (SaaS/Self) |
| **Logic** | Groovy Pipelines | YAML Workflows | YAML Pipelines |
| **Extensibility** | 1800+ Plugins | Marketplace Actions | Integrated Features |
| **Best For** | Complex/Legacy/Private | Cloud-First / GitHub Repo | End-to-End DevOps |

---

## 💡 Real-World Scenario
When a developer pushes code to a "feature branch," a CI job runs unit tests. If they pass, a Pull Request is automatically marked as "Safe to Merge." Once merged to "main," the CD job deploys the app to the staging server and triggers a Slack notification to the QA team.

---

## 🎤 Interview Preparation

### 1. What is the main difference between Continuous Delivery and Continuous Deployment?
In Continuous Delivery, there is a manual approval step before deploying to production. In Continuous Deployment, the transition is fully automated.

### 2. Why is CI important in a team environment?
It prevents "integration hell" by ensuring changes from different developers don't break the codebase when merged.

---

## 🎯 Next Steps
*   **[Jenkins Architecture](../02-Jenkins-Architecture/README.md)**: Deep dive into how Jenkins scales.
