# AWS ECS Deep Dive

Amazon Elastic Container Service (ECS) is a highly scalable, high-performance container orchestration service that supports Docker containers and allows you to easily run and scale containerized applications on AWS.

## 1. Launch Types: Fargate vs. EC2

| Feature | AWS Fargate (Serverless) | Amazon EC2 |
| :--- | :--- | :--- |
| **Management** | AWS manages infrastructure | You manage EC2 instances |
| **Scaling** | Automatic scaling of tasks | You manage Cluster Auto Scaling |
| **Pricing** | Based on vCPU and RAM used | Based on EC2 instance types |
| **Use Case** | Most microservices, quick scaling | Specialized hardware, GPUs, cost-tuning |

## 2. Core Components

- **Cluster**: A logical grouping of tasks or services.
- **Task Definition**: A blueprint (JSON) that describes how to run your container (Image, CPU/RAM, Environment, Logging).
- **Task**: A running instance of a Task Definition.
- **Service**: Maintains a specified number of running tasks and handles integration with a Load Balancer.

## 3. Hands-on: Deploying with Fargate (CLI)

```bash
# 1. Create an ECS Cluster
aws ecs create-cluster --cluster-name "DevOps-Fargate-Cluster"

# 2. Register a Task Definition
# (Assume task-def.json exists with container details)
aws ecs register-task-definition --cli-input-json file://task-def.json

# 3. Create a Service
aws ecs create-service \
    --cluster "DevOps-Fargate-Cluster" \
    --service-name "my-web-service" \
    --task-definition "my-web-app:1" \
    --desired-count 2 \
    --launch-type FARGATE \
    --network-configuration '{
        "awsvpcConfiguration": {
            "subnets": ["subnet-123", "subnet-456"],
            "securityGroups": ["sg-789"],
            "assignPublicIp": "ENABLED"
        }
    }'
```

## 4. ECS Service Discovery & Load Balancing

- **Application Load Balancer (ALB)**: Routes traffic to tasks based on path or host. ECS automatically registers/deregisters tasks with the ALB Target Group.
- **AWS Cloud Map**: Provides service discovery for internal microservices communication via DNS or API.

## 5. Capacity Providers & Auto Scaling

Capacity Providers allow you to define how your cluster uses Fargate (including Fargate Spot) or Auto Scaling Groups.
- **ECS Service Auto Scaling**: Scale the number of tasks based on CloudWatch metrics (CPU/RAM).
- **Cluster Auto Scaling**: (EC2 only) Scales the underlying EC2 instances based on task demand.

## 6. Troubleshooting Guide

| Symptom | Probable Cause | Resolution |
| :--- | :--- | :--- |
| **Task Failure: Essential container in task exited** | Application crash or health check failure | Check logs using `aws logs get-log-events`. |
| **Pending Status (EC2)** | No available capacity in cluster | Add more EC2 instances or check Instance draining status. |
| **Cannot pull container image** | ECR permission or networking issue | Ensure the task execution role has ECR access; verify VPC has internet/endpoint access. |
| **Service not stable** | Health checks failing | Verify the ALB health check path and port match the application. |

---
**Next Step**: Level up to Kubernetes with [AWS EKS Production-Ready Guide](../../../../../../../03-advanced/01-phase-1/04-container-orchestration/enterprise-container-orchestration/aws-eks-production-ready.md)
