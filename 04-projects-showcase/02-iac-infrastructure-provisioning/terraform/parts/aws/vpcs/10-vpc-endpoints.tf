# 10. VPC with Endpoints
# Access AWS services (like S3) privately without an internet gateway.

resource "aws_vpc" "endpoint_vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "VPC-With-S3-Endpoint"
  }
}

# S3 Gateway Endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.endpoint_vpc.id
  service_name = "com.amazonaws.us-east-1.s3"
  
  tags = {
    Name = "S3-Gateway-Endpoint"
  }
}

# Interface Endpoint (e.g., for EC2 API)
resource "aws_vpc_endpoint" "ec2" {
  vpc_id            = aws_vpc.endpoint_vpc.id
  service_name      = "com.amazonaws.us-east-1.ec2"
  vpc_endpoint_type = "Interface"
  
  subnet_ids          = [aws_subnet.endpoint_subnet.id]
  security_group_ids = [aws_security_group.endpoint_sg.id]

  private_dns_enabled = true
}

resource "aws_subnet" "endpoint_subnet" {
  vpc_id     = aws_vpc.endpoint_vpc.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_security_group" "endpoint_sg" {
  vpc_id = aws_vpc.endpoint_vpc.id
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.endpoint_vpc.cidr_block]
  }
}
