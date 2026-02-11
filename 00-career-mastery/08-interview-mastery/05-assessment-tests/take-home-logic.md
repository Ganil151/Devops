# 🏠 Take-Home Project Logic: The "Production-Grade" Standard

Take-homes are the best way for a DevOps engineer to prove their skills. You aren't being timed by a clock, but by your own ability to prioritize quality.

---

## 🏗️ The "Full Stack" DevOps Assignment
A typical take-home might look like: *"Deploy a simple Nginx app on Kubernetes using Terraform and a CI/CD pipeline."*

### The Winning Submission Checklist

#### 1. The "Killer" README
Your solution is graded by its README first. It must include:
- **Architecture Diagram**: (Use Excalidraw or Mermaid.js).
- **Prerequisites**: What do I need to run this? (Terraform version, Docker, etc.)
- **One-Command Start**: `make deploy` or `./run-all.sh`.
- **Trade-offs Section**: "I chose AWS EKS over kops because..." (This shows maturity).

#### 2. Infrastructure as Code (IaC) Standards
- **Variable-Driven**: No hardcoded IPs or secrets.
- **Provider Pinning**: Pin your Terraform providers and K8s versions.
- **State Management**: Even if it's local, mention how you'd do it in production (e.g., S3/DynamoDB).

#### 3. Container Best Practices
- **Multi-Stage Builds**: Keep your images small.
- **Non-Root User**: `USER node` or equivalent. (Security points).
- **Healthchecks**: Add `HEALTHCHECK` to your Dockerfile.

#### 4. The "SRE" Touch (Bonus Points)
A project that merely "works" is a Junior submission. A project that "operates" is a Senior submission. Add:
- **Logging**: Where do the logs go?
- **Monitoring**: Include a simple Prometheus/Grafana dashboard or dummy alerts.
- **Security Scans**: Include a `trivy` or `checkov` report in your PR.

---

## 🛑 Common "Auto-Fail" Mistakes
1. **No README**: If I have to spend 20 minutes figuring out how to run your code, I'll just reject it.
2. **Secrets in Git**: Checking an `.env` file or AWS keys into GitHub is a 100% rejection.
3. **Over-Engineering**: Don't build a multi-region service mesh if the task was just to deploy a local container.
4. **Broken Code**: If it doesn't run on the grader's machine due to local paths or missing dependencies, it's over.

---

## 🏆 The "4-Hour Rule"
Don't spend 40 hours on a take-home. Spend 4 hours.
- **Hour 1**: Functional Code (It runs).
- **Hour 2**: Standardize (Variables, Modules, Cleanliness).
- **Hour 3**: Documentation (README, Diagram).
- **Hour 4**: "Operations" Polish (Security scan, Monitoring metrics).

---
*Back to [Assessment Hub](./readme.md)*
