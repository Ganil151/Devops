# AWS Elastic Load Balancer (ELB) Architectural Patterns

This directory contains 20 common Load Balancer patterns for AWS using Terraform. ELB automatically distributes incoming application traffic across multiple targets, such as Amazon EC2 instances, containers, IP addresses, and Lambda functions.

## 📂 Load Balancer Patterns Overview

| # | Type | Description | File |
|---|------|-------------|------|
| 1 | **Public ALB** | Internet-facing Application Load Balancer. | `01-public-alb.tf` |
| 2 | **Internal ALB** | Private LB for microservices communication. | `02-internal-alb.tf` |
| 3 | **Network LB (NLB)** | High-throughput, low-latency L4 traffic. | `03-network-lb.tf` |
| 4 | **Gateway LB (GWLB)** | managing fleet of security virtual appliances. | `04-gateway-lb.tf` |
| 5 | **HTTP Redirect** | Forcing HTTP traffic to HTTPS (301 Redirect). | `05-http-https-redirect.tf` |
| 6 | **Path Routing** | URL path-based traffic distribution. | `06-path-based-routing.tf` |
| 7 | **Host Routing** | Hostname/Domain-based traffic distribution. | `07-host-based-routing.tf` |
| 8 | **Cognito Auth** | User authentication at the edge via Cognito. | `08-cognito-auth.tf` |
| 9 | **WAF Integration** | Protecting LB with Web Application Firewall. | `09-waf-integration.tf` |
| 10 | **Access Logs** | enabling request logging to an S3 bucket. | `10-access-logs.tf` |
| 11 | **Lambda Target** | Invoking a function as a load balancer target. | `11-lambda-target.tf` |
| 12 | **Instance Target** | Traditional EC2-based target groups. | `12-instance-target.tf` |
| 13 | **IP Target** | Target group for specific private IPs. | `13-ip-target.tf` |
| 14 | **Sticky Sessions** | ensuring clients stick to the same server. | `14-sticky-sessions.tf` |
| 15 | **NLB TLS** | handling SSL/TLS termination at the NLB. | `15-nlb-tls-termination.tf` |
| 16 | **NLB Elastic IP** | Static public IP addresses for the LB. | `16-nlb-elastic-ip.tf` |
| 17 | **Cross-Zone** | Balances traffic across all AZ instances. | `17-cross-zone-lb.tf` |
| 18 | **Dual-Stack** | Support for both IPv4 and IPv6 clients. | `18-dual-stack-lb.tf` |
| 19 | **Idle Timeout** | Adjusting connection timeout settings. | `19-idle-timeout.tf` |
| 20 | **Minimalist** | Baseline boilerplate configuration. | `20-minimalist-lb.tf` |

## 🚀 Architectural Best Practices
1.  **Deletion Protection**: Enable `enable_deletion_protection = true` for production load balancers to prevent accidental removal.
2.  **HTTPS Everywhere**: Always use HTTPS listeners and redirect HTTP to HTTPS.
3.  **Clean Target Groups**: Use specific health check paths instead of the root `/` to ensure the application is ready.
4.  **Least Privilege**: Restrict the security groups of the load balancer to only allow necessary ingress (e.g., 80/443).
5.  **Multi-AZ**: Always deploy the load balancer across multiple Availability Zones for high availability.

## 🛠 Prerequisites
These patterns require an existing VPC and Subnets. you'll need to provide the `vpc_id` and `subnets` list to the resource blocks.
