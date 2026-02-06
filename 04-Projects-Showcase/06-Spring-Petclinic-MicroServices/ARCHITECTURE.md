# 🏛️ Architecture Decision Record (ADR)
This document outlines the architectural decisions made for the Spring PetClinic Microservices deployment to ensure stability, scalability, and security.

## 1. Cloud Infrastructure: AWS + EKS
**Decision**: Use Amazon Web Services (AWS) as the primary cloud provider with Elastic Kubernetes Service (EKS) for orchestration.
**Rationale**: EKS provides a managed control plane, reducing operational overhead while offering deep integration with other AWS services like RDS, ECR, and IAM.

## 2. Infrastructure as Code: Modular Terraform
**Decision**: Implement a "Module-Environment" pattern in Terraform.
**Rationale**: 
- **Modules** provide DRY (Don't Repeat Yourself) code for VPC, EKS, and RDS.
- **Environments** (Dev/Prod) provide physical isolation of state files, ensuring that a misconfiguration in development cannot destroy production resources.

## 3. Database Strategy: Shared RDS vs. Per-Service
**Decision**: Use a single RDS Instance with logical databases for each microservice in the initial phase, moving to dedicated instances for high-traffic services in the future.
**Rationale**: Reduces initial cost while maintaining data isolation at the schema level.

## 4. CI/CD: Jenkins Declarative Pipelines
**Decision**: Use Jenkins with `Jenkinsfile` stored in the source code.
**Rationale**: Jenkins offers flexibility for complex multi-stage pipelines and has extensive support for the Java/Maven ecosystem and AWS integration.

## 5. Security Gates: Static & Dynamic Scanning
**Decision**: Mandatory SonarQube (SAST) and Trivy (Container Scanning).
**Rationale**: By failing the build on High/Critical vulnerabilities, we enforce a "Security Left" culture where issues are fixed before they reach production.

## 6. Communication: REST + Spring Cloud
**Decision**: Synchronous RESTful communication with Spring Cloud Netflix Eureka for service discovery.
**Rationale**: Industry standard for Spring-based microservices, providing robust load balancing and service transparency.

## 8. GenAI Integration: Vertex AI / Bedrock
**Decision**: Integrate a Python-based `genai-service` using LangChain and AWS Bedrock (Claude 3).
**Rationale**: Provides vets with automated clinical summaries and diagnostic suggestions based on historical pet data, demonstrating a modern "AI-Augmented" SRE platform.

## 9. FinOps & Resource Optimization
**Decision**: Implement a multi-layered cost optimization strategy.
- **Compute**: Spot Instances for `Dev` (70% savings).
- **Storage**: S3 Intelligent-Tiering for remote state and logs.
- **Lifecycle**: Automatic scaling down to 0 replicas for non-essential services during weekends in non-production environments.

---
*Last Updated: 2026-02-06*
