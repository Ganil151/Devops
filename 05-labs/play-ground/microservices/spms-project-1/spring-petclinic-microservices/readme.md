# 🏥 Spring PetClinic Microservices: Cloud-Native Showcase
[![Terraform](https://img.shields.io/badge/IaC-Terraform-623CE4?logo=terraform)](https://www.terraform.io/)
[![Kubernetes](https://img.shields.io/badge/Orchestration-Kubernetes-326CE5?logo=kubernetes)](https://kubernetes.io/)
[![Jenkins](https://img.shields.io/badge/CI/CD-Jenkins-D24939?logo=jenkins)](https://www.jenkins.io/)

This repository showcases a production-grade, microservices-based deployment of the classic **Spring PetClinic** application. It is designed to demonstrate advanced DevOps patterns, including Infrastructure as Code (IaC), GitOps, automated security gates, and enterprise-level environment isolation.

## 🏗️ Architecture Overview
The system is composed of several independent microservices, each with a specific domain responsibility, communicating over a high-performance network foundation.

![Architecture Diagram](./images/architecture_diagram.png)

- **API Gateway**: Entry point for all client requests, handling routing and security.
- **Config Server**: Centralized configuration management using Git.
- **Discovery Server**: Service registry (Netflix Eureka/Spring Cloud Discovery).
- **Customers Service**: Manages owner and pet information.
- **Vets Service**: Manages veterinarian data and specialties.
- **Visits Service**: Handles appointment scheduling and history.
- **GenAI Service**: (Enhanced) AI-powered diagnostic suggestions for vets.

## 🚀 Key Features
- **Enterprise IaC**: Multi-environment Terraform structure (Dev/Prod) with state isolation.
- **Automated CI/CD**: End-to-end Jenkins pipeline with automated Slack notifications.
- **Security First**: Integrated Trivy container scanning and SonarQube static analysis.
- **FinOps Optimized**: EKS Spot Instance integration in Dev to reduce costs by up to 90%.
- **Observability**: Prometheus/Grafana stack for real-time monitoring and alerting.

## 📂 Project Structure
```text
.
├── checklist/                     # Operational Readiness Checklists
│   └── LAUNCH_CHECKLIST.md        # Production release requirements
├── terraform/                     # Enterprise IaC (Modular Architecture)
│   ├── environments/              # Environment-specific configurations
│   │   ├── dev/                   # Development (2 AZs, cost-optimized)
│   │   ├── staging/               # Pre-production testing
│   │   └── prod/                  # Production (3 AZs, HA)
│   ├── modules/                   # Reusable infrastructure components
│   │   ├── networking/            # VPC, Subnets, NAT, IGW
│   │   ├── eks/                   # Kubernetes cluster
│   │   ├── rds/                   # MySQL database
│   │   ├── ecr/                   # Container registries
│   │   ├── secrets/               # Secrets Manager
│   │   ├── monitoring/            # CloudWatch logs
│   │   └── alb/                   # Load balancer config
│   ├── shared/                    # Shared configurations
│   ├── scripts/                   # Automation helpers
│   └── README.md                  # Infrastructure documentation
├── helm/                          # K8s manifests and deployment charts
├── scripts/                       # Automation and utility scripts
├── cicd-implementation.md         # Detailed Pipeline Guide
└── README.md                      # You are here
```

## 🛠️ Getting Started

### Prerequisites
- Terraform >= 1.5.0
- AWS CLI configured with credentials
- kubectl >= 1.29
- Docker (for building images)

### Quick Start

1. **Infrastructure Provisioning** (Using Helper Scripts):
   ```bash
   cd terraform
   
   # Initialize environment
   ./scripts/init.sh dev
   
   # Review infrastructure plan
   ./scripts/plan.sh dev
   
   # Deploy infrastructure
   ./scripts/apply.sh dev
   ```

2. **Configure Kubernetes Access**:
   ```bash
   aws eks update-kubeconfig --region us-east-1 --name dev-petclinic-cluster
   kubectl get nodes
   ```

3. **Pipeline Setup**:
   - Refer to the [CI/CD Implementation Guide](./cicd-implementation.md) for Jenkins configuration.

4. **Validation**:
   - Use the [Launch Checklist](./checklist/launch-checklist.md) to verify environment status.
   - Review the [Infrastructure Runbook](./terraform/RUNBOOK_AWS_DEPLOY.md) for detailed deployment steps.

### Environment-Specific Deployment

Deploy to different environments using the same pattern:

```bash
# Staging
./scripts/init.sh staging
./scripts/plan.sh staging
./scripts/apply.sh staging

# Production (requires confirmation)
./scripts/init.sh prod
./scripts/plan.sh prod
./scripts/apply.sh prod
```

## ⚖️ Governance & Standards
This project follows strictly enforced standards for:
- **Cloud Design Patterns**: Sidecar patterns, Circuit Breakers, and Bulkheading.
- **Branching Model**: Trunk-based development with short-lived feature branches.
- **Code Quality**: Hard-fail gates on Critical/High vulnerabilities.

---
*Maintained by the DevOps Engineering Team*
