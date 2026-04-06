terraform {
  # This block is used for Remote State Storage and Locking.
  # UNCOMMENT and update the values below after you have created the S3 bucket and DynamoDB table.

  /*
  backend "s3" {
    bucket         = "YOUR-UNIQUE-STATE-BUCKET-NAME"
    key            = "automation-track/terraform-patterns/terraform.tfstate"
    region         = "us-east-1"
    
    # Enable state locking via DynamoDB
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
  */
}

# Example of a 'moved' block for refactoring practice
# moved {
#   from = aws_instance.old_instance
#   to   = aws_instance.new_instance
# }
