# 03. Encrypted S3 Bucket (SSE-S3)
# Uses Amazon S3-managed keys for server-side encryption by default.

resource "aws_s3_bucket" "encrypted_sse_s3" {
  bucket = "encrypted-sse-s3-${random_id.bucket_id.hex}"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse_s3" {
  bucket = aws_s3_bucket.encrypted_sse_s3.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
