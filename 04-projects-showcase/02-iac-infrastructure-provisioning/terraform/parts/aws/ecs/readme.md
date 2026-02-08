# Amazon ECS Architectural Patterns

This directory contains 20 common Elastic Container Service (ECS) patterns for AWS using Terraform. ECS is a highly scalable, high-performance container orchestration service that supports Docker containers and allows you to easily run and scale containerized applications on AWS.

## 📂 ECS Patterns Overview

| # | Type | Description | File |
|---|------|-------------|------|
| 1 | **Basic Cluster** | Minimal cluster with Container Insights enabled. | `01-basic-cluster.tf` |
| 2 | **Fargate Task** | serverless container definition with roles. | `02-fargate-task.tf` |
| 3 | **Fargate Service** | managing desired count and LB integration. | `03-fargate-service.tf` |
| 4 | **EC2 Task** | Container definition for EC2-based tasks. | `04-ec2-task.tf` |
| 5 | **EC2 Service** | Running containers on managed EC2 fleets. | `05-ec2-service.tf` |
| 6 | **Capacity Prov** | Fargate vs Fargate Spot distribution. | `06-capacity-providers.tf` |
| 7 | **Autoscaling** | Target tracking based on CPU/Memory. | `07-ecs-autoscaling.tf` |
| 8 | **CW Logs** | integrating awslogs driver for task output. | `08-cloudwatch-logs.tf` |
| 9 | **EFS Volumes** | Persistent data storage for containers. | `09-efs-volumes.tf` |
| 10 | **Scheduled Task** | Recurring cron jobs via EventBridge. | `10-scheduled-task.tf` |
| 11 | **Secrets Manager** | secure environment variable injection. | `11-secrets-management.tf` |
| 12 | **Blue/Green** | Deployments via CodeDeploy traffic shifting. | `12-blue-green-service.tf` |
| 13 | **Networking** | VPC integration and traffic monitoring. | `13-vpc-networking.tf` |
| 14 | **Service Connect** | Internal microservices logical naming (DNS). | `14-service-connect.tf` |
| 15 | **App Mesh** | complex traffic control via Envoy proxy sidecar. | `15-app-mesh.tf` |
| 16 | **Storage** | Boosting ephemeral disk space up to 200GB. | `16-ephemeral-storage.tf` |
| 17 | **Windows** | Running .NET Framework apps on Windows Server. | `17-windows-containers.tf` |
| 18 | **ECS Exec** | Interactive shell access into containers. | `18-ecs-exec-enabled.tf` |
| 19 | **Graviton (ARM)** | high-efficiency ARM64 computing. | `19-graviton-tasks.tf` |
| 20 | **Minimalist** | Baseline cluster boilerplate. | `20-minimalist-ecs.tf` |

## 🚀 Key Best Practices
1.  **Fargate First**: Prefer **Fargate** for its serverless nature unless you have specific EC2 requirements (GPUs, extremely high memory).
2.  **Separate Roles**: Use different IAM roles for **Execution** (pulling images, logging) and **Task** (application permissions).
3.  **Soft/Hard Limits**: Set memory and CPU limits appropriately to prevent a single container from starving others.
4.  **Security Groups**: Narrowly define security group rules to only allow traffic from the Load Balancer or specific CIDRs.
5.  **Task Placement**: For EC2 launch types, use **Placement Strategies** (binpack/spread) to optimize cost and availability.

## 🛠 Prerequisites
ECS requires an IAM Execution Role and and optionally a Task Role. services typically require an Application Load Balancer (ALB) and associated subnets.
