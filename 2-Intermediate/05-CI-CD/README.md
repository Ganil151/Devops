# CI/CD: Continuous Integration & Deployment

CI/CD is the heart of DevOps, bridging the gap between development and operations by automating the software delivery lifecycle. This module covers the core principles and the industry-standard tools used to build resilient pipelines.

---

## 🗺️ The CI/CD Learning Path

Follow these modules in order to master modern software delivery:

1.  **[01-CI-CD-Fundamentals](./01-CI-CD-Fundamentals/README.md)**: Master the theory of CI, CD, and Continuous Deployment.
2.  **[02-Jenkins-Mastery](./02-Jenkins-Mastery/README.md)**: Learn the most popular automation server and Jenkinsfile syntax.
3.  **[GitLab CI/CD](../04-Repository-Management/02-GitLab/README.md)**: GitLab pipelines and CI/CD (see Repository Management).
4.  **[04-Static-Code-Analysis-SonarQube](./04-Static-Code-Analysis-SonarQube/README.md)**: Implement automated code quality and security gates.
5.  **[05-Interview-Questions-and-Quizzes](./05-Interview-Questions-and-Quizzes/README.md)**: Test your knowledge and prepare for technical screenings.
6.  **[06-Real-Life-Scenarios](./06-Real-Life-Scenarios/README.md)**: Practical troubleshooting and architecture challenges.
7.  **[📺 YouTube Lessons](./Youtube_Lessons.md)**: Curated video tutorials for visual learning.

---

## 🏗️ 1. Core Philosophies
- **Automate Everything**: If a human is doing it, it should be a script.
- **Fail Fast**: Detect errors as early as possible (Shift-Left).
- **Parity**: Keep Dev, Staging, and Production environments as similar as possible.
- **Immutable Artifacts**: Build once, deploy everywhere.

---

## 🛡️ Tool Overview

### Jenkins
The "Swiss Army Knife" of CI/CD. Extremely flexible with thousands of plugins.
- *Best for*: Complex legacy workflows and highly customized automation.

### GitLab CI
Highly integrated, modern, and container-native CI/CD. See **[Repository Management - GitLab](../04-Repository-Management/02-GitLab/README.md)** for complete coverage.
- *Best for*: Teams already using GitLab who want an "all-in-one" experience.

### SonarQube
The "Quality Guardian." Analyzes code for bugs, vulnerabilities, and technical debt.
- *Best for*: Enforcing coding standards across large teams.

---

## ✅ Knowledge Check
- [x] Explain the difference between Continuous Delivery and Continuous Deployment.
- [x] Create a basic pipeline in Jenkins or GitLab.
- [x] Understand how to use SonarQube to block insecure code.
- [x] Pass the 20-Question assessment in the Quiz folder.
- [x] Describe a Blue-Green deployment strategy.

---

## 🔗 Next Steps
- **[Kubernetes & Helm](../07-Kubernetes/)** - Orchestrate your containerized applications.
- **[Observability Foundations](../10-Observability-Foundations/)** - Monitor your applications after they are deployed.

---
*Build it, test it, ship it. Automatically.*