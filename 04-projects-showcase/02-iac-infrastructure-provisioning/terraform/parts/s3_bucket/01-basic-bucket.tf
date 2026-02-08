# 01. Basic S3 Bucket
# Minimal configuration with a unique name.

resource "random_id" "bucket_id" {
  byte_length = 8
}

resource "aws_s3_bucket" "basic" {
  bucket = "basic-bucket-${random_id.bucket_id.hex}"

  tags = {
    Name        = "Basic-Storage-Bucket"
    Environment = "Dev"
  }
}
