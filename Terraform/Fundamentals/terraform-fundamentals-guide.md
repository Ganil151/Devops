# Terraform Fundamentals Guide

## Table of Contents
1. [What is Terraform](#what-is-terraform)
2. [Core Concepts](#core-concepts)
3. [Installation and Setup](#installation-and-setup)
4. [Configuration Language](#configuration-language)
5. [Providers](#providers)
6. [Resources](#resources)
7. [Variables and Outputs](#variables-and-outputs)
8. [Data Sources](#data-sources)
9. [Terraform Workflow](#terraform-workflow)
10. [Basic Examples](#basic-examples)

## What is Terraform

Terraform is an open-source Infrastructure as Code (IaC) tool created by HashiCorp that allows you to define and provision infrastructure using a declarative configuration language.

### Key Benefits
- **Infrastructure as Code**: Version control your infrastructure
- **Multi-Cloud**: Support for 1000+ providers
- **Declarative**: Describe desired state, not steps
- **Plan and Apply**: Preview changes before execution
- **State Management**: Track resource relationships
- **Modular**: Reusable infrastructure components

### Use Cases
- **Cloud Infrastructure**: AWS, Azure, GCP resources
- **Multi-Cloud Deployments**: Consistent infrastructure across clouds
- **Application Infrastructure**: Kubernetes, Docker, databases
- **Network Infrastructure**: VPCs, load balancers, DNS
- **Security Infrastructure**: IAM, security groups, certificates

## Core Concepts

### Infrastructure as Code Principles
```
┌─────────────────────────────────────────────────────────────┐
│                    IaC Workflow                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                   Write                             │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │ Resources   │  │ Variables   │  │   Modules   │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
│                           │                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                    Plan                             │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │   Validate  │  │   Preview   │  │   Review    │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
│                           │                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                   Apply                             │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │   Create    │  │   Update    │  │   Destroy   │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Terraform Architecture
- **Configuration Files**: `.tf` files defining infrastructure
- **State File**: Tracks current infrastructure state
- **Providers**: Plugins for cloud platforms and services
- **Resources**: Infrastructure components to manage
- **Modules**: Reusable configuration packages

## Installation and Setup

### Installation Methods
```bash
# Method 1: Download binary
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Method 2: Package manager (Ubuntu/Debian)
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Method 3: Using tfenv (version manager)
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
tfenv install 1.6.0
tfenv use 1.6.0

# Verify installation
terraform version
```

### Initial Setup
```bash
# Create project directory
mkdir terraform-project
cd terraform-project

# Initialize Terraform
terraform init

# Create main configuration file
touch main.tf

# Create variables file
touch variables.tf

# Create outputs file
touch outputs.tf
```

## Configuration Language

### HCL Syntax Basics
```hcl
# Comments start with #

# Block syntax
resource "resource_type" "resource_name" {
  argument1 = "value1"
  argument2 = "value2"
  
  nested_block {
    nested_argument = "nested_value"
  }
}

# Variable declaration
variable "example_var" {
  description = "An example variable"
  type        = string
  default     = "default_value"
}

# Local values
locals {
  common_tags = {
    Environment = "production"
    Project     = "web-app"
  }
}

# Output values
output "example_output" {
  description = "An example output"
  value       = resource.resource_type.resource_name.attribute
}
```

### Data Types
```hcl
# String
variable "name" {
  type    = string
  default = "example"
}

# Number
variable "count" {
  type    = number
  default = 3
}

# Boolean
variable "enabled" {
  type    = bool
  default = true
}

# List
variable "availability_zones" {
  type    = list(string)
  default = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

# Map
variable "tags" {
  type = map(string)
  default = {
    Environment = "production"
    Team        = "devops"
  }
}

# Object
variable "server_config" {
  type = object({
    name = string
    size = string
    tags = map(string)
  })
  default = {
    name = "web-server"
    size = "t3.micro"
    tags = {
      Environment = "production"
    }
  }
}
```

### Functions and Expressions
```hcl
# String functions
locals {
  upper_name = upper(var.name)
  formatted  = format("server-%s", var.name)
  joined     = join("-", ["web", "server", "01"])
}

# Collection functions
locals {
  first_az    = element(var.availability_zones, 0)
  az_count    = length(var.availability_zones)
  unique_list = distinct(var.availability_zones)
}

# Conditional expressions
locals {
  instance_type = var.environment == "production" ? "t3.large" : "t3.micro"
  
  tags = merge(
    var.common_tags,
    {
      Name = var.instance_name
    }
  )
}

# For expressions
locals {
  # Create list
  az_names = [for az in var.availability_zones : upper(az)]
  
  # Create map
  az_map = {for i, az in var.availability_zones : i => az}
  
  # Filter list
  prod_azs = [for az in var.availability_zones : az if contains(az, "us-west")]
}
```

## Providers

### Provider Configuration
```hcl
# AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# Multiple provider configurations
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_west_2"
  region = "us-west-2"
}
```

### Multi-Provider Example
```hcl
# Multiple cloud providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

provider "azurerm" {
  features {}
}

provider "google" {
  project = var.gcp_project_id
  region  = "us-central1"
}
```

## Resources

### Basic Resource Syntax
```hcl
# AWS EC2 Instance
resource "aws_instance" "web_server" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro"
  
  tags = {
    Name        = "web-server"
    Environment = "production"
  }
}

# AWS S3 Bucket
resource "aws_s3_bucket" "app_bucket" {
  bucket = "my-app-bucket-${random_string.suffix.result}"
}

resource "aws_s3_bucket_versioning" "app_bucket_versioning" {
  bucket = aws_s3_bucket.app_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Random string for unique naming
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}
```

### Resource Dependencies
```hcl
# Implicit dependency (reference)
resource "aws_instance" "web_server" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public.id  # Implicit dependency
  
  tags = {
    Name = "web-server"
  }
}

# Explicit dependency
resource "aws_instance" "app_server" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro"
  
  depends_on = [
    aws_security_group.app_sg,
    aws_key_pair.app_key
  ]
  
  tags = {
    Name = "app-server"
  }
}
```

### Resource Meta-Arguments
```hcl
# Count
resource "aws_instance" "web_servers" {
  count         = 3
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro"
  
  tags = {
    Name = "web-server-${count.index + 1}"
  }
}

# For_each with list
resource "aws_instance" "web_servers_list" {
  for_each = toset(["web", "app", "db"])
  
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro"
  
  tags = {
    Name = "${each.value}-server"
    Type = each.value
  }
}

# For_each with map
resource "aws_instance" "web_servers_map" {
  for_each = {
    web = "t3.micro"
    app = "t3.small"
    db  = "t3.medium"
  }
  
  ami           = "ami-0c02fb55956c7d316"
  instance_type = each.value
  
  tags = {
    Name = "${each.key}-server"
    Type = each.key
  }
}

# Lifecycle rules
resource "aws_instance" "persistent_server" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro"
  
  lifecycle {
    prevent_destroy = true
    ignore_changes  = [ami, user_data]
    
    create_before_destroy = true
  }
  
  tags = {
    Name = "persistent-server"
  }
}
```

## Variables and Outputs

### Variable Types and Validation
```hcl
# String variable with validation
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"
  
  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be development, staging, or production."
  }
}

# Number variable with validation
variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
  
  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10."
  }
}

# Complex object variable
variable "database_config" {
  description = "Database configuration"
  type = object({
    engine         = string
    engine_version = string
    instance_class = string
    allocated_storage = number
    multi_az       = bool
    backup_retention_period = number
  })
  
  default = {
    engine         = "mysql"
    engine_version = "8.0"
    instance_class = "db.t3.micro"
    allocated_storage = 20
    multi_az       = false
    backup_retention_period = 7
  }
}

# Sensitive variable
variable "database_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}
```

### Output Values
```hcl
# Simple output
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web_server.id
}

# Sensitive output
output "database_endpoint" {
  description = "Database endpoint"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}

# Complex output
output "instance_details" {
  description = "Details of all instances"
  value = {
    for instance in aws_instance.web_servers :
    instance.tags.Name => {
      id         = instance.id
      public_ip  = instance.public_ip
      private_ip = instance.private_ip
    }
  }
}

# Conditional output
output "load_balancer_dns" {
  description = "Load balancer DNS name"
  value       = var.create_load_balancer ? aws_lb.main[0].dns_name : null
}
```

## Data Sources

### Common Data Sources
```hcl
# AWS AMI data source
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# AWS availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# AWS VPC data source
data "aws_vpc" "default" {
  default = true
}

# AWS subnets data source
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Current AWS caller identity
data "aws_caller_identity" "current" {}

# Current AWS region
data "aws_region" "current" {}
```

### Using Data Sources
```hcl
# Use AMI from data source
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  
  tags = {
    Name = "web-server"
  }
}

# Use availability zones from data source
resource "aws_subnet" "public" {
  count = length(data.aws_availability_zones.available.names)
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}
```

## Terraform Workflow

### Basic Commands
```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Format configuration files
terraform fmt

# Plan changes
terraform plan

# Apply changes
terraform apply

# Show current state
terraform show

# List resources in state
terraform state list

# Destroy infrastructure
terraform destroy
```

### Advanced Commands
```bash
# Plan with variable file
terraform plan -var-file="production.tfvars"

# Apply with auto-approve
terraform apply -auto-approve

# Plan with target resource
terraform plan -target=aws_instance.web_server

# Import existing resource
terraform import aws_instance.web_server i-1234567890abcdef0

# Refresh state
terraform refresh

# Output specific value
terraform output instance_id

# Show state of specific resource
terraform state show aws_instance.web_server

# Move resource in state
terraform state mv aws_instance.old_name aws_instance.new_name

# Remove resource from state
terraform state rm aws_instance.web_server
```

## Basic Examples

### Simple Web Server
```hcl
# main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

# Security group
resource "aws_security_group" "web_sg" {
  name_prefix = "web-sg"
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "web-security-group"
  }
}

# EC2 instance
resource "aws_instance" "web_server" {
  ami                    = "ami-0c02fb55956c7d316"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Terraform!</h1>" > /var/www/html/index.html
              EOF
  
  tags = {
    Name = "web-server"
  }
}

# Output
output "instance_public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web_server.public_ip
}

output "instance_public_dns" {
  description = "Public DNS of the web server"
  value       = aws_instance.web_server.public_dns
}
```

### Multi-Tier Architecture
```hcl
# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "main-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "main-igw"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  count = 2
  
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

# Private Subnet
resource "aws_subnet" "private" {
  count = 2
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = {
    Name = "public-route-table"
  }
}

# Route Table Association
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)
  
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Load Balancer
resource "aws_lb" "main" {
  name               = "main-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id
  
  tags = {
    Name = "main-alb"
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "web" {
  name                = "web-asg"
  vpc_zone_identifier = aws_subnet.private[*].id
  target_group_arns   = [aws_lb_target_group.web.arn]
  health_check_type   = "ELB"
  
  min_size         = 2
  max_size         = 6
  desired_capacity = 2
  
  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }
  
  tag {
    key                 = "Name"
    value               = "web-server"
    propagate_at_launch = true
  }
}
```

This fundamentals guide provides a solid foundation for understanding Terraform concepts and getting started with Infrastructure as Code.