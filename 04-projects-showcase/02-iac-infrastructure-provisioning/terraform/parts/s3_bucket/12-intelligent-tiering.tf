# 12. S3 Bucket with Intelligent-Tiering
# Automatically moves objects between frequent and infrequent access tiers based on usage.

resource "aws_s3_bucket" "intelligent_tiering" {
  bucket = "cost-optimized-bucket-${random_id.bucket_id.hex}"
}

resource "aws_s3_bucket_intelligent_tiering_configuration" "main" {
  bucket = aws_s3_bucket.intelligent_tiering.id
  name   = "EntireBucket"

  tiering {
    access_tier = "ARCHIVE_ACCESS"
    days        = 90
  }

  tiering {
    access_tier = "DEEP_ARCHIVE_ACCESS"
    days        = 180
  }
}
