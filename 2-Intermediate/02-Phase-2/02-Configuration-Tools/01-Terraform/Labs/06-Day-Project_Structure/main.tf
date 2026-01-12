
# create s3 bucket
resource "aws_s3_bucket" "demo_bucket" {
  bucket = "gsmash-demo-bucket-name-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "MyBucket 0.3.0"
    Environment = "Dev"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# VPC for security group
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "demo-vpc"
  }
}

# Subnet for EC2 instance
resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "demo-subnet"
  }
}

# EC2 Instance - Demonstrating all type constraints
resource "aws_instance" "web_server" {
  # String type: AMI ID and instance type
  ami           = "ami-0e8459476fed2e23b"
  instance_type = var.instance_type

  # Number type: Instance count
  count = var.instance_count

  # Bool type: Enable monitoring and public IP
  monitoring                  = var.enable_monitoring
  associate_public_ip_address = var.associate_public_ip

  # Set type: Availability zone (using first element from set)
  availability_zone = "us-east-1a"
  subnet_id         = aws_subnet.main.id

  # List type: Security group
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # Object type: Using server config object attributes
  # Note: This demonstrates object access syntax
  # instance_type could also be: var.server_config.instance_type
  # monitoring could also be: var.server_config.monitoring

  # Map type: Tags
  tags = var.instance_tags

  # Root block device using number type
  root_block_device {
    volume_size = var.storage_size
    volume_type = "gp3"
  }
}

# Security Group for EC2
resource "aws_security_group" "web_sg" {
  # String type: Name and description
  name        = "${var.server_config.name}-sg" # Object type usage
  description = "Security group for web server"
  vpc_id      = aws_vpc.main.id

  # HTTP access using tuple type (port number from network_config[2])
  ingress {
    from_port   = var.network_config[2] # Tuple type: third element (number)
    to_port     = var.network_config[2] # Tuple type: third element (number)
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks # List type
  }

  # SSH access  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks # List type
  }

  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Map type: Tags
  tags = var.instance_tags
}

