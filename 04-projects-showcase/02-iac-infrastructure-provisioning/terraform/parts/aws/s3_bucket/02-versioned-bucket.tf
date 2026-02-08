# 02. S3 Bucket with Versioning
# Maintains multiple versions of an object for data protection.

resource "aws_s3_bucket" "versioned" {
  bucket = "versioned-bucket-${random_id.bucket_id.hex}"
}

resource "aws_s3_bucket_versioning" "versioned" {
  bucket = aws_s3_bucket.versioned.id
  versioning_configuration {
    status = "Enabled"
  }
}
