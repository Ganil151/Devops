# Security & Compliance

> **Enterprise security, secrets management, and compliance automation**

## Core Concept: Identity-Driven Security
**[REFERENCE: Enterprise Secrets \u0026 Vault](./reference/enterprise-secrets-architecture-ref.md)**

Transitioning from static passwords to a dynamic, identity-based security model:
- **Dynamic Credentials**: Utilizing HashiCorp Vault to generate short-lived, just-in-time secrets for databases and cloud APIs.
- **Identity-First Auth**: Linking application identity (K8s ServiceAccounts) directly to security policies.
- **Cryptography as a Service**: Offloading encryption and key management to a central "Transit" engine to prevent key exfiltration.

## Enterprise Governance: Continuous Compliance
**[REFERENCE: Policy as Code \u0026 Compliance](./reference/policy-as-code-compliance-ref.md)**

Moving beyond static audits to real-time, automated policy enforcement:
- **Policy as Code (OPA/Rego)**: Encoding regulatory requirements (SOC2, PCI-DSS) into machine-readable logic enforced at the API gate.
- **Admission Control Guardrails**: Utilizing OPA Gatekeeper to block non-compliant infrastructure and workloads before they reach the cluster.
- **Automated Evidence Collection**: Systematically capturing API logs and configuration snapshots to provide continuous proof of compliance.
- **Compensating Controls**: Implementing automated "Self-Healing" security rules that remediate violations (e.g., closing public ports) within seconds of detection.

---

## 📚 Modules in This Part

1. **[01-Supply-Chain-SLSA-SBOM](./01-supply-chain-slsa-sbom/)** - 01 Supply Chain SLSA SBOM
2. **[02-Runtime-Security-Compliance](./02-runtime-security-compliance/)** - 02 Runtime Security Compliance
3. **[03-Secrets-Management-Vault](./03-secrets-management-vault/)** - 03 Secrets Management Vault
4. **[04-Admission-Control-OPA](./04-admission-control-opa/)** - 04 Admission Control OPA
5. **[05-Security-Scanning-SAST-DAST](./05-security-scanning-sast-dast/)** - 05 Security Scanning SAST DAST
6. **[06-Compliance-Auditing](./06-compliance-auditing/)** - 06 Compliance Auditing


---

## 🎯 Learning Path

These modules should be completed in the order shown above for optimal learning progression.

### Prerequisites:
- Solid understanding of Kubernetes
- Experience with cloud platforms (AWS/GCP/Azure)
- Familiarity with GitOps principles

### Estimated Time:
- Total: 48-72 hours
- Per module: ~8-12 hours

---

## 🔗 Related Parts

- [Part 1: Service Mesh](readme.md) - mTLS
- [Part 2: GitOps](readme.md) - Security pipelines


---

**Part of**: [Advanced Phase-2: Strategic Skills](../readme.md)
