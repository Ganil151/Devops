terraform {
  backend "local" {
    path = "/Users/ganil/Documents/Web-Design-/Terraform/aws-intance/Youtube_Lessons/state-file/terrafrm.tfstate"
  }
  required_providers {
    local = {
      source = "hashicorp/local"
      version = "2.5.3"
    }
  }
}