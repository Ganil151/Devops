# 10. S3 Bucket with Object Lock
# Prevents objects from being deleted or overwritten for a specified period.

resource "aws_s3_bucket" "compliance" {
  bucket = "compliance-lock-bucket-${random_id.bucket_id.hex}"

  object_lock_enabled = true
}

resource "aws_s3_bucket_object_lock_configuration" "compliance" {
  bucket = aws_s3_bucket.compliance.id

  rule {
    default_retention {
      mode = "COMPLIANCE"
      days = 5
    }
  }
}
