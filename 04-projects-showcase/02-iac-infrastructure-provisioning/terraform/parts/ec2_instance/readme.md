# AWS EC2 Instance Architectural Patterns

This directory contains 20 common Elastic Compute Cloud (EC2) patterns for AWS using Terraform. EC2 provides resizable compute capacity in the cloud.

## 📂 EC2 Types Overview

| # | Type | Description | File |
|---|------|-------------|------|
| 1 | **Amazon Linux 2** | Standard AWS-native Linux distro. | `01-amazon-linux.tf` |
| 2 | **Ubuntu 20.04** | Canonical's popular open-source distro. | `02-ubuntu-instance.tf` |
| 3 | **Windows Server** | Enterprise Windows workspace. | `03-windows-instance.tf` |
| 4 | **User Data (Shell)** | Automated setup via bash script (Nginx). | `04-user-data-shell.tf` |
| 5 | **Cloud-init (YAML)** | Advanced configuration via cloud-init. | `05-user-data-cloud-init.tf` |
| 6 | **IAM Role** | Instance access to AWS services via profiles. | `06-iam-role-instance.tf` |
| 7 | **Elastic IP** | Provisioning a static public IP. | `07-elastic-ip.tf` |
| 8 | **EBS Volumes** | Adding persistent block storage. | `08-ebs-volume.tf` |
| 9 | **Spot Instance** | Using spare capacity for deep cost savings. | `09-spot-instance.tf` |
| 10 | **Unlimited CPU** | Enabling burstable performance without limits. | `10-unlimited-burst.tf` |
| 11 | **Key Pair** | managing SSH access via key files. | `11-key-pair.tf` |
| 12 | **Protection** | Preventing accidental termination. | `12-termination-protection.tf` |
| 13 | **Monitoring** | Detailed 1-minute CloudWatch metrics. | `13-detailed-monitoring.tf` |
| 14 | **Private EC2** | Deployment in isolated private subnets. | `14-private-subnet-ec2.tf` |
| 15 | **Block Device** | Custom Root Volume configuration. | `15-root-block-device.tf` |
| 16 | **IMDSv2** | Hardened security for metadata access. | `16-metadata-options.tf` |
| 17 | **Compute Optimized**| C5 series for batch/processing tasks. | `17-compute-optimized.tf` |
| 18 | **Memory Optimized** | R5 series for DBs and real-time apps. | `18-memory-optimized.tf` |
| 19 | **Graviton (ARM)** | High performance/price ARM-based nodes. | `19-graviton-instance.tf` |
| 20 | **Minimalist** | Barebones starting point. | `20-minimalist-ec2.tf` |

## 🚀 Technical Best Practices
1.  **Use Data Sources for AMIs**: Avoid hardcoding AMI IDs. Use `data "aws_ami"` to always get the latest patched version.
2.  **IAM Roles over Keys**: Never store AWS access keys on instances. Use **IAM Instance Profiles**.
3.  **IMDSv2**: Require Token-based metadata access (`http_tokens = "required"`) to mitigate SSRF vulnerabilities.
4.  **Tag Everything**: Use consistent tagging (e.g., `Environment`, `Owner`, `Project`) for cost tracking.
5.  **Termination Protection**: Enable for critical/production instances.

## 🛠 Prerequisites
These files are modular. Ensure you have your `vpc_id` and `subnet_id` variables ready if you plan to deploy them into a specific network.
