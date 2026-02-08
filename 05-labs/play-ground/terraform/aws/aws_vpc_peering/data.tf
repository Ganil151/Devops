data "aws_availability_zones" "primary" {
  state = available
  provider =  aws.primary
}

