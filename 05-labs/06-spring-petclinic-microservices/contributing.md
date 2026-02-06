# 🤝 Contributing to PetClinic DevOps
Welcome! This project follows a professional SRE/DevOps workflow. Please adhere to these guidelines to maintain the integrity of our infrastructure and automation.

## 🌿 Branching Strategy
We use **GitHub Flow** (Trunk-based development with short-lived feature branches).
- `main`: Production-ready code. Only merged via Pull Request from `dev`.
- `dev`: Integration branch for testing.
- `feature/*`: New features or infrastructure changes.
- `fix/*`: Bug fixes.

## 🛠️ Development Workflow
1. **Local Validation**:
   - For Terraform: Run `terraform validate` and `terraform fmt`.
   - For Helm: Run `helm lint ./helm/microservices`.
2. **Pull Requests (PR)**:
   - All PRs must target the `dev` branch first.
   - A minimum of one peer review is required.
   - The Jenkins CI pipeline must pass all checks (Unit Tests, SonarQube, Trivy).
3. **Deployment**:
   - Merges to `dev` trigger a deployment to the Development EKS cluster.
   - Merges from `dev` to `main` require a manual approval gate in Jenkins before production deployment.

## 📝 Commit Message Convention
We follow [Conventional Commits](https://www.conventionalcommits.org/):
- `feat`: A new feature or infrastructure resource.
- `fix`: A bug fix.
- `docs`: Documentation changes.
- `style`: Formatting, missing semi-colons, etc.
- `refactor`: Refactoring code without changing functionality.
- `ci`: Changes to CI/CD configuration.

## 📊 Quality Standards
- **SonarQube**: No "Blocker" or "Critical" issues allowed.
- **Trivy**: Zero High/Critical vulnerabilities in production images.
- **Terraform**: Must use remote state with encryption and locking enabled.

---
*Thank you for contributing to the showcase!*
