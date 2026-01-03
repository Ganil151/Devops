# CI/CD Fundamentals

CI/CD is the backbone of modern software delivery. It automates the transition from code commit to production deployment.

---

## 🏗️ Core Concepts

### 1. Continuous Integration (CI)
The practice of merging all developer working copies to a shared mainline several times a day.
- **Goal**: Detect bugs early via automated builds and tests.
- **Outcome**: A "Green Build" that is ready for further stages.

### 2. Continuous Delivery (CD)
An expansion of CI where the team ensures that every change can be deployed to production at any time.
- **Manual Gate**: The final push to production usually requires manual approval.

### 3. Continuous Deployment (CD)
The most advanced stage where every change that passes the automated pipeline is automatically deployed to production without human intervention.

---

## 🛠️ The Pipeline Stages

1. **Commit**: Developer pushes code to Git.
2. **Build**: The CI server compiles code and builds an artifact (e.g., Jar, Docker Image).
3. **Test**: Unit tests, integration tests, and security scans (SonarQube).
4. **Deploy to Staging**: Infrastructure as Code (Terraform/Ansible) sets up the environment.
5. **Acceptance Tests**: End-to-end testing on the staging environment.
6. **Production Release**: Final deployment to the live environment.

---

## 💡 Why CI/CD?
- **Speed**: Fail fast, fix fast.
- **Reliability**: Automation eliminates human error during deployment.
- **Consistency**: The same artifact is promoted through all environments.
- **Feedback**: Developers get immediate feedback on their code quality.
