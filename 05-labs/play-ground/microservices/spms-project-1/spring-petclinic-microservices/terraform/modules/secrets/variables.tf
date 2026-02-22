variable "environment" { type = string }
variable "password" { 
  type      = string 
  sensitive = true
}
