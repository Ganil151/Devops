# 🔐 Enterprise Security Policy & Guardrails
This document outlines the security posture and mandatory compliance checks for the Spring PetClinic Microservices project.

## 🛡️ 1. Infrastructure Hardening
- **Private Networking**: All microservices and RDS instances are hosted in **Private Subnets**. Access is routed through the API Gateway (ALB).
- **Security Groups**: Principle of Least Privilege (PoLP). Only Port 80/443 is open to the Load Balancer; internal services communicate only over specific application ports.
- **IAM Policies**: Terraform roles and Pod Execution roles use narrowly defined policies with `Resource: "*"` explicitly forbidden for sensitive actions.

## 🔍 2. Automated Vulnerability Management
- **SAST (Static Analysis)**: Every build is scanned by **SonarQube**. 
    - *Threshold*: Zero "Critical" or "Blocker" issues.
- **SCA (Software Composition Analysis)**: **Trivy** scans container images for vulnerable libraries.
    - *Action*: Pipeline fails if a HIGH or CRITICAL vulnerability is detected in the base image.
- **Secret Scanning**: Pre-commit hooks and CI scans prevent AWS Keys or DB Credentials from being committed to Git.

## 🔑 3. Secrets Management
- All sensitive data (DB Passwords, API Keys) is stored in **AWS Secrets Manager**.
- **CSI Secrets Store Driver**: Secrets are injected into pods as volumes or environment variables at runtime, never stored on disk or in the Docker image.

## 🚦 4. Runtime Security
- **RBAC**: Kubernetes Role-Based Access Control limits what developers and applications can do within the cluster.
- **Network Policies**: Kubernetes NetworkPolicies restrict cross-namespace traffic and egress to unknown IPs.

---
## 🚨 Incident Reporting
If you discover a security vulnerability, please report it via an Incident Ticket or contact the SRE On-call immediately. Do not open a public issue.

---
*Maintained by the DevOps & SecOps Team*
