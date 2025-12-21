# Enterprise DevSecOps: Security as Code

Security is not a gated process at the end of development; it must be a continuous thread that runs through every stage of the DevOps lifecycle. This is the "Shift-Left" philosophy.

---

## ⬅️ The Shift-Left Philosophy

Shift-Left means moving security testing to the earliest possible stage (the "left" of the timeline).

1. **Plan/Code**: Static code analysis (SAST) and secret scanning in the IDE.
2. **Build**: Scanning dependencies for known vulnerabilities (SCA).
3. **Deploy**: Scanning Docker images and verifying infrastructure configurations (IaC Scanning).
4. **Operate**: Runtime security, intrusion detection, and automated compliance audits.

---

## 🛠️ Core Security Tooling

- **[Trivy](../../00-Resources/01-Scripts-Code/SonarQube/)**: The standard for scanning containers, file systems, and configuration files for vulnerabilities.
- **[SonarQube](../../2-Intermediate/05-CI-CD/sonarQube/)**: Continuous inspection of code quality and security.
- **[OPA (Open Policy Agent)](../03-Advanced-K8s/Compliance/)**: A unified policy engine to enforce security rules as code (Gatekeeper).
- **[Vault/Secrets Manager](../05-Identity-Governance/)**: Centralized management of sensitive keys and passwords.

---

## 📜 Key Security Modules

### 1. [Secret Management](./Secret-Management/README.md)
Ensuring no credentials are ever hardcoded. Using dynamic secrets and rotation.

### 2. [Compliance-as-Code](./Compliance-As-Code/README.md)
Automating the evidence collection for SOC2, HIPAA, or ISO audits.

### 3. [Image Hardening](./Image-Scanning/README.md)
Building minimal rootless images (Distroless) to reduce the attack surface.

---

## 💡 Best Practices
- **Fail the Build**: If a high-severity vulnerability is found, the CI/CD pipeline must stop immediately.
- **Immutable Security**: Security policies should be version-controlled just like code.
- **Trust Nothing**: Implement Mutual TLS (mTLS) for all internal service communication.

---
**Identity**: Learn how to manage user and service permissions in the [Identity & Governance Module](../05-Identity-Governance/README.md).
