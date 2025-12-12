# AWS Terraform Projects

This folder contains practical Terraform projects for AWS infrastructure deployment.

## Project Structure

```
Aws_Projects/
├── Youtube_Lessons/          # Educational projects from tutorials
│   └── terraform_server_v1/  # Basic server deployment project
├── Production_Examples/      # Production-ready templates
├── Multi_Tier_Apps/         # Multi-tier application architectures
└── Microservices/           # Microservices infrastructure patterns
```

## Available Projects

### Youtube_Lessons
- **terraform_server_v1** - Basic EC2 server deployment with security groups and networking

### Production Examples (Coming Soon)
- **web-app-infrastructure** - Complete web application infrastructure
- **database-cluster** - RDS cluster with read replicas
- **container-platform** - ECS/EKS container orchestration

### Multi-Tier Applications (Coming Soon)
- **three-tier-web-app** - Web, application, and database tiers
- **microservices-platform** - Complete microservices infrastructure
- **serverless-api** - API Gateway + Lambda + DynamoDB

## Getting Started

1. Choose a project based on your needs
2. Navigate to the project directory
3. Review the README.md for specific instructions
4. Customize variables in `terraform.tfvars`
5. Deploy with standard Terraform workflow

```bash
cd Aws_Projects/Youtube_Lessons/terraform_server_v1
terraform init
terraform plan
terraform apply
```

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform installed (version >= 1.0)
- Basic understanding of AWS services
- SSH key pair for EC2 access

## Security Notes

- All projects follow AWS security best practices
- Sensitive values should be stored in AWS Secrets Manager
- Use IAM roles instead of hardcoded credentials
- Enable CloudTrail and GuardDuty for monitoring