terraform {
  required_version = ">= 1.14.1, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.49.0"
    }
  }
  backend "s3" {
    bucket       = "dev-gsmash-tf-bucket"
    key          = "eks/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = var.aws-region
}


# # Add the following to the in the terminal
# aws s3api create-bucket \
#     --bucket dev-gsmash-tf-bucket \
#     --region us-east-1

# Enable versioning
# aws s3api put-bucket-versioning \
#     --bucket dev-gsmash-tf-bucket \
#     --versioning-configuration Status=Enabled

# # Enable server-side encryption
# aws s3api put-bucket-encryption \
#     --bucket dev-gsmash-tf-bucket \
#     --server-side-encryption-configuration '{
#         "Rules": [{
#             "ApplyServerSideEncryptionByDefault": {
#                 "SSEAlgorithm": "AES256"
#             }
#         }]
#     }'