terraform {
  backend "s3" {
    bucket       = "finishline-infra-app-8e2f686"
    key          = "dev/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
