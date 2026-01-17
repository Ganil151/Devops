# -----------------------------------------------------------------------------
# Name: variables.tf / main.tf
# Description: Advanced HCL concepts (Data Sources, Locals, Loops).
# -----------------------------------------------------------------------------

# 1. Variables with Validation
variable "environment" {
  type        = string
  default     = "dev"
  description = "Target environment"
  
  validation {
    condition     = contains(["dev", "prod", "test"], var.environment)
    error_message = "Environment must be dev, prod, or test."
  }
}

# 2. Data Sources (Finding existing infra)
data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# 3. Locals (Centralized names/logic)
locals {
  common_tags = {
    Project     = "CloudMigration"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# 4. Resource with Dynamic Count
resource "aws_instance" "app_server" {
  count         = var.environment == "prod" ? 3 : 1
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = "t3.micro"
  
  tags = merge(locals.common_tags, { Name = "Server-${count.index}" })
}
