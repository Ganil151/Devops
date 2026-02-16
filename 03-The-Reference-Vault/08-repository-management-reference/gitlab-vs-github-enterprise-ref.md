# GitLab vs GitHub Enterprise: Technical Comparison

**Doc Version:** 1.0.0
**Role:** Senior DevOps Engineer
**Scope:** Architecture & CI/CD Engines

---

## 1. CI/CD Engines

### GitHub Actions (`.github/workflows`)
- **Structure:** YAML files located in `.github/workflows`.
- **Event-Driven:** Triggers on `push`, `pull_request`, `issue_comment`, etc.
- **Composition:** Uses "Actions" (reusable units of code) from the Marketplace.
- **Syntax:**
  ```yaml
  name: CI
  on: [push]
  jobs:
    build:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v2
  ```

### GitLab CI (`.gitlab-ci.yml`)
- **Structure:** A single `.gitlab-ci.yml` in the root (includes can split it).
- **Stage-Driven:** Defines stages (build, test, deploy) explicitly.
- **Composition:** Script-heavy. Relies more on shell scripts inside containers.
- **Syntax:**
  ```yaml
  stages:
    - build
  
  build_job:
    stage: build
    script:
      - echo "Building..."
  ```

---

## 2. Runner Architectures

### GitHub Runners
- **Hosted:** Provided by Azure (Windows/Linux/macOS).
- **Self-Hosted:** Can be installed on any machine.
- **Security:** "Ephemeral" runners are harder to set up self-hosted without external tools (like Actions Runner Controller on K8s).

### GitLab Runners
- **Architecture:** Go binary. Highly scalable.
- **Executors:** Shell, Docker, Docker+Machine, Kubernetes (native integration).
- **Security:** Tightly integrated. Easy to register specific runners for protected branches/tags.

---

## 3. Security & Governance

### GitHub Advanced Security (GHAS)
- **Dependabot:** Automated dependency updates.
- **CodeQL:** Semantic code analysis engine.
- **Secret Scanning:** Scans for tokens pushed to repos.
- **Cost:** Often an add-on for Enterprise.

### GitLab Ultimate
- **Container Scanning:** Built-in.
- **SAST/DAST:** Integrated directly into the Merge Request view.
- **Secret Detection:** Runs as a job in the pipeline.
- **Compliance:** Strong focus on "Audit events" and "Compliance frameworks".

## Summary
- **GitHub:** Developer experience is king. Community-driven Actions ecosystem.
- **GitLab:** "All-in-one" DevOps platform. stronger native K8s integration and compliance features.
