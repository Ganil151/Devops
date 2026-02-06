# 🏥 Spring PetClinic Microservices: Cloud-Native Showcase
[![Terraform](https://img.shields.io/badge/IaC-Terraform-623CE4?logo=terraform)](https://www.terraform.io/)
[![Kubernetes](https://img.shields.io/badge/Orchestration-Kubernetes-326CE5?logo=kubernetes)](https://kubernetes.io/)
[![Jenkins](https://img.shields.io/badge/CI/CD-Jenkins-D24939?logo=jenkins)](https://www.jenkins.io/)

This repository showcases a production-grade, microservices-based deployment of the classic **Spring PetClinic** application. It is designed to demonstrate advanced DevOps patterns, including Infrastructure as Code (IaC), GitOps, automated security gates, and enterprise-level environment isolation.

## 🏗️ Architecture Overview
The system is composed of several independent microservices, each with a specific domain responsibility, communicating over a high-performance network foundation.

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
├── checklist/                  # Operational Readiness Checklists
│   └── LAUNCH_CHECKLIST.md     # Production release requirements
├── terraform/                  # Enterprise IaC (Multi-environment)
│   ├── environments/           # Dev/Prod root modules
│   └── modules/                # Reusable LEGO-style modules
├── helm/                       # K8s manifests and deployment charts
├── scripts/                    # Automation and utility scripts
├── CICD_IMPLEMENTATION.md      # Detailed Pipeline Guide
└── README.md                   # You are here
```

## 🛠️ Getting Started
To begin deploying or contributing to this showcase, please follow these steps:

1. **Infrastructure Provisioning**:
   - Navigate to `terraform/environments/dev`.
   - Run `terraform init` and `terraform apply`.
2. **Pipeline Setup**:
   - Refer to the [CI/CD Implementation Guide](./CICD_IMPLEMENTATION.md) for Jenkins configuration.
3. **Validation**:
   - Use the [Launch Checklist](./checklist/LAUNCH_CHECKLIST.md) to verify your environment status.

## ⚖️ Governance & Standards
This project follows strictly enforced standards for:
- **Cloud Design Patterns**: Sidecar patterns, Circuit Breakers, and Bulkheading.
- **Branching Model**: Trunk-based development with short-lived feature branches.
- **Code Quality**: Hard-fail gates on Critical/High vulnerabilities.

---
*Maintained by the DevOps Engineering Team*
