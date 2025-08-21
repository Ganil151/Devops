# main.tf

module "key_pair" {
  source   = "./modules/key_pair"
  key_name = var.key_name
}

module "security_group" {
  source = "./modules/security_group"
  petclinic_vpc = var.petclinic_vpc_id
  ingress_rules = [
    {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["148.101.252.23/32"]
    },
    {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Eureka Server"
      from_port   = 8761
      to_port     = 8761
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Config Server"
      from_port   = 8888
      to_port     = 8888
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "API Gateway"
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Zipkin Server"
      from_port   = 9411
      to_port     = 9411
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Admin Server"
      from_port   = 9090
      to_port     = 9090
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Frontend App"
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Notification Service"
      from_port   = 9091
      to_port     = 9091
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

  ]
}

module "ec2_instance" {
  source                      = "./modules/ec2_instance"
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = module.key_pair.key_name
  user_data                   = var.user_data
  user_data_replace_on_change = var.user_data_replace_on_change
  associate_public_ip_address = var.associate_public_ip_address
  subnet_id                   = aws_subnet.petclinic_subnet.id
  security_group_id           = module.security_group.security_group_id
}


resource "aws_subnet" "petclinic_subnet" {
  vpc_id                  = aws_vpc.petclinic_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "petclinic-subnet"
  }
}

resource "aws_internet_gateway" "petclinic_igw" {
  vpc_id = aws_vpc.petclinic_vpc.id
  tags = {
    Name = "petclinic-igw"
  }
}

resource "aws_route_table" "petclinic_public_rt" {
  vpc_id = aws_vpc.petclinic_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.petclinic_igw.id
  }
  tags = {
    Name = "petclinic-public-rt"
  }
}

resource "aws_route_table_association" "petclinic_public_rt_assoc" {
  subnet_id      = aws_subnet.petclinic_subnet.id
  route_table_id = aws_route_table.petclinic_public_rt.id
}

resource "aws_vpc" "petclinic_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "petclinic-vpc"
  }
}
