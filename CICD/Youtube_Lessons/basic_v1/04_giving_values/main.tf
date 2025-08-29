terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }
  }
}

resource "local_file" "example" {
  content = "The God content"  
  filename = "${path.module}/${var.filename}.txt"
}