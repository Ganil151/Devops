variable "vpc_id" {}
variable "project_name" {}
variable "ingress_rules" {
  type = list(number)
}
variable "egress_rules" {
  type    = list(number)
  default = [0]
}
