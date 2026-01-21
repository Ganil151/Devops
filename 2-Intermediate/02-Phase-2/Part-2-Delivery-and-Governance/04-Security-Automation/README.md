# 🟡 Container Security Scanning (Intermediate)

## 📚 Overview

Mastering automated vulnerability scanning using **Trivy**. This module covers how to integrate scanning into the developer workflow and CI/CD pipelines to achieve "Shift-Left Security."

## 🎯 Learning Objectives

- ✅ Install and configure **Trivy** for local and remote scans.
- ✅ Implement **Image Layer Analysis** to find hidden vulnerabilities.
- ✅ Configure CI/CD (GitHub Actions/GitLab) to fail builds on finding CRITICAL vulnerabilities.
- ✅ Manage vulnerability "Ignore lists" (False positives).

---

## 🏗️ Visual: Shift-Left Container Scanning

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant Git as Git Repo
    participant CI as CI Pipeline
    participant T as Trivy Scanner
    participant Reg as Container Registry

    Dev->>Git: push code
    Git->>CI: trigger build
    CI->>CI: Build Image
    CI->>T: Scan Image
    Alt Vulnerability Found
        T-->>CI: Fail (Status 1)
        CI-->>Dev: Alert: "Build Failed - Critical Sec Risk"
    Else Scan Clean
        T-->>CI: Success (Status 0)
        CI->>Reg: push image
    End
```

---

## 🛠️ Tooling: Trivy CLI Snippets
Trivy is the most popular scanner because it is fast, stateless, and supports many formats.

**Scan an image**:
```bash
trivy image --severity HIGH,CRITICAL python:3.9-slim
```

**Scan a filesystem**:
```bash
trivy fs --security-checks vuln,config .
```

**Output as JSON (for automation)**:
```bash
trivy image --format json --output results.json my-app:latest
```

---
**Next Step**: [Trivy Implementation](./01-Trivy-Implementation/) 🚀
