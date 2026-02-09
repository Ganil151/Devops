# Terraform Architectural Patterns Library

This directory serves as a comprehensive library of **300+ reusable Terraform patterns** for AWS infrastructure provisioning. Each sub-directory focuses on a specific AWS service, providing 20 different configuration patterns ranging from basic setups to enterprise-grade architectures involving high availability, security, and compliance.

## 📂 Library Contents

| Component | Description | Patterns |
|-----------|-------------|----------|
| [**VPCs**](./vpcs/) | Virtual Private Cloud designs (Isolation, Peering, Transit). | 20 |
| [**Subnets**](./subnet/) | Public, Private, Isolated, and Specialized subnet layouts. | 20 |
| [**Security Groups**](./security_groups/) | Firewall rules for Web, DB, App, and Management layers. | 20 |
| [**S3 Buckets**](./s3_bucket/) | Static sites, Encryption, Logging, Replication, and Locks. | 20 |
| [**Route Tables**](./route_table/) | Routing via IGW, NAT, TGW, VPN, and VPC Peering. | 20 |
| [**RDS**](./rds/) | MySQL, Postgres, Aurora, Serverless, and Replicas. | 20 |
| [**EC2 Instances**](./ec2_instance/) | OS-specific, Graviton, Spot, and Custom UserData. | 20 |
| [**IAM**](./iam/) | Users, Roles, Policies, OIDC, and Boundaries. | 20 |
| [**Lambda**](./lambda/) | Python, Node, VPC, Triggers, Layers, and Versions. | 20 |
| [**Load Balancers**](./load_balancer/) | ALB, NLB, GWLB, Path Routing, and WAF Integration. | 20 |
| [**EKS**](./eks/) | Clusters, Node Groups, Fargate, IRSA, and Encryption. | 20 |
| [**DynamoDB**](./dynamodb/) | On-Demand, GSI/LSI, Streams, Global Tables, and DAX. | 20 |
| [**CloudFront**](./cloudfront/) | CDN distributions, OAC, Security Headers, and WAF. | 20 |
| [**Messaging**](./messaging/) | SQS, SNS, EventBridge, Filters, and DLQs. | 20 |
| [**ECS**](./ecs/) | Fargate, EC2 fleets, Autoscaling, and Service Connect. | 20 |
| [**CloudWatch**](./cloudwatch/) | Alarms, Dashboards, Logs, and Synthetics Canaries. | 20 |

## 🚀 How to Use This Library

1.  **Browse by Service**: Navigate into a sub-directory to see specific resource configurations.
2.  **Copy-Paste Patterns**: Copy the `.tf` block into your own module or project.
3.  **Check Prerequisites**: Each directory has a `readme.md` detailing the required variables (like `vpc_id` or `subnet_ids`).
4.  **Best Practices**: Refer to the "Best Practices" section in each component's README for SRE-grade implementation tips.

## 🛡 Security & Compliance
All patterns are designed with the **AWS Well-Architected Framework** in mind, emphasizing:
- encryption-at-rest and in-transit.
- Principle of Least Privilege (PoLP).
- High Availability across multiple Availability Zones.
- Monitoring and Auditability.

---
*Created as part of the DevOps Showcase - Infrastructure as Code Module.*
