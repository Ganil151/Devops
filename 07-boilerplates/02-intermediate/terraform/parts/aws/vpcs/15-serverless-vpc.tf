# 15. Serverless VPC
# Optimized for Lambda and API Gateway integration.

resource "aws_vpc" "serverless_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true # Required for Private Link / Lambda
  enable_dns_hostnames = true

  tags = {
    Name = "Serverless-Infrastructure-VPC"
  }
}

# Subnets specifically for Lambda functions
resource "aws_subnet" "lambda_subnet_az1" {
  vpc_id            = aws_vpc.serverless_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  
  tags = {
    Name = "Lambda-Compute-Subnet"
  }
}

# Usually paired with VPC Endpoints for S3/DynamoDB if functions are in private subnets
