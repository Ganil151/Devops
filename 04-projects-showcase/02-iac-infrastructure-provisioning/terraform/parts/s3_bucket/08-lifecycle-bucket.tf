# 08. S3 Bucket with Lifecycle Rules
# Automatically transitions objects to cheaper storage classes or deletes them.

resource "aws_s3_bucket" "lifecycle" {
  bucket = "lifecycle-managed-bucket-${random_id.bucket_id.hex}"
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.lifecycle.id

  rule {
    id     = "archive-and-cleanup"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}
