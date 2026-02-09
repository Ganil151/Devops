# 04. KMS Encrypted S3 Bucket (SSE-KMS)
# Uses a Customer Master Key (CMK) in AWS KMS for encryption.

resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "encrypted_sse_kms" {
  bucket = "encrypted-sse-kms-${random_id.bucket_id.hex}"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse_kms" {
  bucket = aws_s3_bucket.encrypted_sse_kms.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
