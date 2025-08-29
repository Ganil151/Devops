terraform {
  backend "s3" {
    bucket  = "add bucket name here"
    key     = "jupiter-website-ecs.tfstate"
    region  = "us-east-1"
    profile = "add the name of the access key & secret key here"
  }
}
