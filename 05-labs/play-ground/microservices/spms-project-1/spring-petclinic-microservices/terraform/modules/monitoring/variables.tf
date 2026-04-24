variable "environment" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "db_identifier" {
  type = string
}

variable "alarm_actions" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
