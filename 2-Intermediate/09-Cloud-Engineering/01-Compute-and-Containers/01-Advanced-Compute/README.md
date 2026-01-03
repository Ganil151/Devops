# Advanced Compute Services - Intermediate

Compute is the engine of your cloud workload. This module moves beyond basic instances to advanced orchestration and serverless execution environments.

---

## 1. Choosing the Right Compute

AWS provides multiple ways to run your code. Choosing the right one depends on your management preference and scaling needs.

| Service | Level of Control | Ideal Use Case |
| :--- | :--- | :--- |
| **Amazon EC2** | High (Full OS access) | Custom apps, legacy vertical scaling. |
| **Amazon ECS** | Medium (Task-based) | Dockerized microservices. |
| **AWS Fargate** | Low (Serverless) | "Set it and forget it" containers. |
| **AWS Lambda** | Minimal (Function-based) | Event-driven code, small tasks. |

---

## 2. Core Modules

### 🖥️ [EC2 Comprehensive Guide](aws-ec2-comprehensive.md)
Master instance types, AMIs, User Data scripts, and Instance Metadata.

### 🐳 [ECS & Fargate Deep Dive](aws-ecs-fargate-guide.md)
Advanced orchestration, Task Definitions, and Service Auto Scaling for containers.

---

## 3. Deployment Best Practices
- **Use Auto Scaling Groups (ASG)**: Never run a production EC2 instance without an ASG; it provides self-healing and elasticity.
- **Image Hardening**: Regularly update your AMIs and Docker base images for security patches.
- **Infrastructure as Code**: Always use Terraform or CloudFormation to deploy compute resources to ensure reproducibility.

---
**Advanced Orchestration**: Learn about Kubernetes in the [AWS EKS Production Guide](../../Advanced-Level/16-Container-Orchestration/README.md)