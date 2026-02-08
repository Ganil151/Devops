data "aws_availability_zones" "primary" {
  state = available
  provider =  aws.primary
}

data "aws_availability_zones" "secondary" {
  state = available
  provider =  aws.secondary
}

data "aws_ami" "primary_ami" {
  provider = aws.primary
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  
}