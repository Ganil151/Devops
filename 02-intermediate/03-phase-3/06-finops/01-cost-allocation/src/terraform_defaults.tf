# Best practice for FinOps: Global Default Tags
# This ensuring that every resource created by this provider 
# inherits the base governance tags automatically.

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = "Production"
      Project     = "Alpha-Order-System"
      Owner       = "sre-team@company.com"
      CostCenter  = "CC-9988-FIN"
      ManagedBy   = "Terraform"
    }
  }
}

# Individual resources can still override or add to these tags
# resource "aws_instance" "web" {
#   ami           = "ami-123456"
#   instance_type = "t3.medium"
#   tags = {
#     Name = "Web-Server-01"
#   }
# }
