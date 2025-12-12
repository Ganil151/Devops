# Practical Trivy Examples

Real-world scenarios and practical implementations of Trivy security scanning.

## Contents

- **[real-world-scenarios.md](./real-world-scenarios.md)** - Comprehensive real-world scenarios covering:
  - Multi-cloud container registry scanning
  - Kubernetes cluster security assessment
  - CI/CD security gate implementation
  - SOC 2 compliance reporting
  - Supply chain security assessment

## Scenarios Covered

### 1. Multi-Cloud Registry Scanning
- AWS ECR, Google GCR, Azure ACR integration
- Centralized security reporting
- Cross-registry vulnerability tracking
- Automated alerting and notifications

### 2. Kubernetes Security Assessment
- Cluster-wide container scanning
- Configuration security analysis
- Pod security policy validation
- Runtime security monitoring

### 3. CI/CD Security Gates
- Pipeline integration patterns
- Security threshold enforcement
- Automated deployment blocking
- Compliance validation workflows

### 4. Compliance Reporting
- SOC 2 audit trail generation
- Vulnerability tracking and remediation
- Executive summary reporting
- Audit evidence collection

### 5. Supply Chain Security
- Dependency vulnerability analysis
- SBOM generation and management
- Risk assessment automation
- Vendor security evaluation

## Implementation Examples

Each scenario includes:
- Complete working scripts
- Configuration templates
- Integration patterns
- Monitoring and alerting
- Reporting and compliance

## Quick Start

```bash
# Multi-registry scanning
./multi-registry-scan.sh

# Kubernetes assessment
./k8s-cluster-scan.sh default

# Compliance reporting
./soc2-compliance-report.sh 30

# Supply chain assessment
./supply-chain-assessment.sh
```