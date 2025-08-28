This video demonstration covers the building and deployment of a Java Web Application using various DevOps tools and technologies, such as:
- Git - Version Control System
- GitHub - Source Code Manager
- Terraform - Infrastructure-as-Code
- Jenkins - CI/CD Tool
- Maven - Java Build Tool
- Ansible - Configuration Management and Deployment
- Docker - Image Containerization Tool
- Kubernetes - Container Orchestration Tool
- Amazon Web Services - Cloud Platform


## Create a Terraform Setup:
terraform {
  required_version = "~>1.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>6.0"
    }
  }

  backend "s3" {
    bucket = "terra-app-register"         
    key    = "jenkins/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_dynamodb_table" "tf_lock" {
  name           = "terraform-lock"
  hash_key       = "LockID"
  read_capacity  = 3
  write_capacity = 3
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name = "Terraform Lock Table" #to destroy, add flag --lock=false

  }
  lifecycle {
    prevent_destroy = true #to destroy, change to false
  }
}

---

## Create Main file ##
resource "aws_instance" "JenkinsServer" {
  ami                    = data.aws_ami.amazonlinux.id
  instance_type          = var.my_instance_type
  key_name               = var.my_key
  vpc_security_group_ids = [aws_security_group.vpc-ssh.id, aws_security.vpc-web.id]

  tags = {
    Name = "Jenkins-Server"
  }
}

---

## Data file ## 

data "aws_ami" "amazonlinux2" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

---

# Create Security Group - SSH Traffic and other ports
resource "aws_security_group" "web-traffic" {
  name = "My_Security_Group1"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    "Name" = "My_SG1"
  }
}

---

## Variables ##
variable "region" {
  type    = string
  default = "us-east-2"
}
variable "my_instance_type" {
  type    = string
  default = "t2.micro"
}


variable "my_key" {
  description = "AWS EC2 Key pair that needs to be associated with EC2 Instance"
  type        = string
  default     = "OhioKey"
}

variable "ingressrules" {
  type    = list(number)
  default = [22, 80, 443, 8080, 8090, 9000, 8081, 2479]
}

variable "egressrules" {
  type    = list(number)
  default = [25, 80, 443, 8080, 8090, 3306, 53]
}

---

## Main file ## 
resource "aws_instance" "JenkinsServer" {
  ami                    = data.aws_ami.amazonlinux2.id
  instance_type          = var.my_instance_type
  key_name               = var.my_key
  vpc_security_group_ids = [aws_security_group.web-traffic.id]

  tags = {
    "Name" = "Jenkins-Server"
  }
}

---

## ---- Create an IAM Role for the server with admin access ----## 

### Trust policy (goes under IAM Role → Trust relationships):
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Principal": {
				"Service": "ec2.amazonaws.com"
			},
			"Action": "sts:AssumeRole"
		}
	]
}

### Permissions policy (attach this as inline policy or managed policy to the same role):
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::terra-app-register/*"
    },
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::terra-app-register"
    }
  ]
}


### Example how to add IAM policy in Terraform
resource "aws_iam_role" "terraform_role" {
  name = "terraform-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "s3_policy" {
  role = aws_iam_role.terraform_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::terra-app-register",
          "arn:aws:s3:::terra-app-register/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "terraform_role" {
  name = "terraform-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com" # ✅ keep if EC2 is running Terraform
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "s3_policy" {
  role = aws_iam_role.terraform_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::terra-app-register",
          "arn:aws:s3:::terra-app-register/*"
        ]
      },
      {
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = aws_iam_role.terraform_role.arn
      }
    ]
  })
}
