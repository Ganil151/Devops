data "aws_availability_zones" "primary" {
  state = available
  provider =  aws.primary
}

data "aws_availability_zones" "secondary" {
  state = available
  provider =  aws.secondary
}

data "aws_ami" "primary_ami" {