# 🏗️ Showcase: Global Microservices Mesh Deployment

This project is a high-fidelity demonstration of the **Full DevOps Lifecycle**. It combines every tier of this repository into a single, production-ready architectural pattern.

---

## 🏛️ Architectural Overview

This showcase deploys a **Spring-PetClinic** microservices application across a globally distributed infrastructure.

```mermaid
graph TD
    subgraph AWS_Cloud [AWS Enterprise Account]
        subgraph VPC_Managed [VPC: Global-Net]
            EKS[EKS Cluster: Primary]
            RDS[(RDS: Multi-AZ PostgreSQL)]
            Vault[HashiCorp Vault: Secrets]
        end
    end

    subgraph CI_CD [Pipeline & Orchestration]
        Jenkins[Jenkins: Blueprint V4]
        Argo[ArgoCD: GitOps Fleet]
        Sonar[SonarQube: Quality Gates]
    end

    Developer[Git Merge] --> Jenkins
    Jenkins --> Sonar
    Sonar --> |Success| Argo
    Argo --> |Reconcile| EKS
    EKS --> |Sidecar| Istio[Istio Service Mesh]
    Istio --> |mTLS| App[Microservices]
```

---

## 🛠️ The Professional Tech Stack

- **Provisioning**: Terraform (VPC, EKS, RDS).
- **Configuration**: Ansible (Security Hardening, Vault Setup).
- **Delivery**: [Jenkins Enterprise Blueprint](../../05-Jenkins-Blueprints/blueprint-enterprise-k8s-full.groovy).
- **Security**:
  - **Istio**: Zero-Trust mTLS.
  - **Trivy**: Container vulnerability scanning.
  - **Vault**: CSI Secret Provider.
- **Observability**: Prometheus, Grafana, and Kiali (Service Mapping).

---

## 🚀 Key Learning Objectives

1. **Shift-Left Governance**: Policy-as-Code (OPA) integrated into the Terraform plan before execution.
2. **Automated Quality Gates**: Blocking the release if SonarQube code coverage is < 80% or Trivy finds CRITICAL vulnerabilities.
3. **GitOps Discipline**: Re-syncing the cluster automatically if a human makes manual changes via `kubectl`.
4. **Network Resilience**: Implementing Circuit Breakers to prevent cascading failures between services.

---

## 📁 Project Structure

- **[infra/](./infra/)**: Terraform modules for AWS EKS provisioning.
- **[pipeline/](./pipeline/)**: The customized `Jenkinsfile` based on our Enterprise Blueprint.
- **[gitops/](./gitops/)**: ArgoCD ApplicationSet manifests for automated delivery.

---

## 📋 Implementation Roadmap

- [x] **Phase 1**: Base Networking (VPC, Subnets, NAT Gateway).
- [x] **Phase 2**: EKS Control Plane & Worker Node provisioning via Terraform.
- [x] **Phase 3**: Istio Control Plane & Gateway installation via Helm.
- [x] **Phase 4**: CI/CD integration with [Jenkinsfile](./Jenkinsfile) and security scans.
- [x] **Phase 5**: [GitOps](./gitops/) reconciliation and automated drift detection.

---

### Deployment Philosophy

*"Building at this level isn't about running commands; it's about architecting systems that sustain themselves."*
