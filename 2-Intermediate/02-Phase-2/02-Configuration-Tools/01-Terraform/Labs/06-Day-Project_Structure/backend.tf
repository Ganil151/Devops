terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket       = "gsmash-demo-bucket-name-123456"
    key          = "dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true # Correct way to enable locking
  }

}

# Note: Ensure that the S3 bucket and DynamoDB table exist before using this backend configuration.
# The backend configuration above ensures that Terraform uses the S3 bucket and DynamoDB tabl
# for storing the state file and managing state locks, respectively.
# Also, make sure that the bucket name and DynamoDB table name match those created in main.tf.
