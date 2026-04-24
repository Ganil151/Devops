# 🏗️ CI/CD Pipeline: Definition of Done Checklist

> **"A pipeline that doesn't fail fast is just a slow way to find bugs. Integration is only 'Continuous' if it is verified automatically."**

This checklist acts as the quality gate for any CI/CD implementation in this portfolio. A project is not considered "Done" until every applicable checkbox below is verified.

---

## 1. Pipeline Architecture & Orchestration

- [ ] **Implementation of "Fail-Fast" Logic**
    - **The "Why"**: Minimizes developer wait time and resource consumption by stopping the pipeline at the first sign of trouble (e.g., a linting error).
    - **Verification**: Cause a linting error in a local commit; verify the pipeline terminates before the build/test stage.
    - **Command**: `grep -i "fail" Jenkinsfile` or check the `onFailure` logic in your YAML.

- [ ] **Artifact Versioning & Immutability**
    - **The "Why"**: Ensures that the exact code tested in CI is what gets deployed to production. Prevents "works on my machine" issues caused by changing dependencies.
    - **Verification**: Check the artifact repository (Nexus/Artifactory/Docker Hub) for unique tags (e.g., Commit SHA) rather than just `latest`.
    - **Command**: `docker images` to verify unique tagging patterns.

---

## 2. Code Quality & Validation

- [ ] **Automated Linting (Static Analysis)**
    - **The "Why"**: Enforces team coding standards and catches common errors (e.g., unused variables, syntax issues) without human review.
    - **Verification**: Run the linting tool locally and via the CI pipeline.
    - **Command**: `flake8 .` (Python), `npm run lint` (JS), or `hadolint Dockerfile`.

- [ ] **Unit Testing with Coverage Minimums**
    - **The "Why"**: Guarantees that individual code components function as expected. High coverage reduces the risk of regressions.
    - **Verification**: Pipeline logs must show a passing test suite and a coverage report meeting the threshold (e.g., 80%).
    - **Command**: `pytest --cov=app tests/` or `go test -cover`.

---

## 3. Deployment & Release Management

- [ ] **Environment-Specific Configuration (Externalized)**
    - **The "Why"**: Decouples code from configuration. The same artifact should run in Dev, Staging, and Prod by simply changing environment variables.
    - **Verification**: Verify that no credentials or environment-specific URLs are hardcoded in the application source.
    - **Command**: `grep -r "http://" .` or check for `.env` usage.

- [ ] **Deployment Gates & Manual Approvals (for Prod)**
    - **The "Why"**: Provides a safety mechanism for production releases while keeping lower environment deployments fully automated.
    - **Verification**: Attempt to deploy to production; verify the pipeline pauses for a manual sign-off.
    - **Command**: Check for `input` steps in Jenkins or `environment: production` protection in GitHub Actions.

---

## 4. Security & Compliance

- [ ] **Secret Scanning in Pipeline**
    - **The "Why"**: Prevents catastrophic data breaches by ensuring no API keys or passwords accidentally enter the version control system.
    - **Verification**: Verify a scanning tool is integrated into the pre-build or build stage.
    - **Command**: `gitleaks detect --source . -v` or check for `trufflehog` logs.

- [ ] **Vulnerability Scanning (SCA)**
    - **The "Why"**: Detects known vulnerabilities in third-party libraries and dependencies (Software Composition Analysis).
    - **Verification**: Review the pipeline output for a list of CVEs and the build status (should fail on 'High' or 'Critical').
    - **Command**: `snyk test` or `trivy fs .`.

---

## ❓ Professional Validation (Interview Readiness)

1. **Q: Why do we separate build and deploy stages?**
   - *A: To build the artifact once and deploy it many times. This ensures that the code running in Production is exactly what was tested in CI.*

2. **Q: How does "Idempotency" apply to a deployment pipeline?**
   - *A: Running the same deployment twice should result in the same final state without causing errors or duplicated resources.*

3. **Q: What is the benefit of using a 'Jenkinsfile' or 'actions.yaml' over manual UI configuration?**
   - *A: "Pipeline-as-Code" allows for version control, peer reviews, and audit trails of the automation logic itself.*
