# Terraform Server V1 - Basic EC2 Deployment

This project demonstrates basic Terraform concepts by deploying multiple EC2 instances with a web server.

## What This Project Creates

- Multiple EC2 instances (configurable count)
- Security group with HTTP and SSH access
- Apache web server on each instance
- Basic HTML page showing server information

## Prerequisites

- AWS CLI configured with credentials
- Terraform installed (>= 1.0)
- AWS key pair created in your target region

## Quick Start

1. **Clone and navigate to project**
   ```bash
   cd terraform_server_v1
   ```

2. **Create terraform.tfvars**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. **Deploy infrastructure**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Access your servers**
   - Use the output URLs to access web servers
   - SSH using the key pair you specified

5. **Clean up**
   ```bash
   terraform destroy
   ```

## Configuration Options

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `aws_region` | AWS region | `us-west-2` | `us-east-1` |
| `project_name` | Project name prefix | `terraform-server-v1` | `my-web-app` |
| `instance_count` | Number of instances | `2` | `3` |
| `instance_type` | EC2 instance type | `t3.micro` | `t3.small` |
| `key_name` | AWS key pair name | `my-key` | `your-key-name` |

## Scaling Examples

### Scale to 5 instances
```hcl
instance_count = 5
```

### Use different instance types
```hcl
instance_type = "t3.small"
```

### Deploy in different region
```hcl
aws_region = "us-east-1"
```

## Outputs

After deployment, you'll see:
- **instance_ids**: List of EC2 instance IDs
- **instance_public_ips**: Public IP addresses
- **instance_public_dns**: Public DNS names
- **security_group_id**: Security group ID
- **web_urls**: Direct URLs to access web servers

## Architecture

```
Internet
    |
Security Group (HTTP:80, SSH:22)
    |
EC2 Instances (1-10)
    |
Apache Web Server
```

## Learning Objectives

This project teaches:
- Basic Terraform syntax and structure
- Using variables and outputs
- Working with data sources
- Resource dependencies
- Using count for multiple resources
- Basic AWS resource management

## Next Steps

After mastering this project:
1. Add VPC and subnet configuration
2. Implement load balancer
3. Add auto-scaling groups
4. Explore Terraform modules
5. Add monitoring and logging

## Troubleshooting

**Common Issues:**

1. **Key pair not found**
   - Ensure the key pair exists in your AWS region
   - Check the key_name variable matches exactly

2. **Permission denied**
   - Verify AWS credentials are configured
   - Check IAM permissions for EC2, VPC operations

3. **Instance launch failed**
   - Verify the AMI is available in your region
   - Check if instance type is available in the AZ