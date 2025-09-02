variable "region" {
  type    = string
  default = "us-east-1"
}
variable "my_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "my_instance_type" {
  description = "EC2 instance type"
  type        = map(string)
  default     = {
    small  = "t2.micro"
    medium = "t2.medium"
    large  = "t2.large"
  }
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