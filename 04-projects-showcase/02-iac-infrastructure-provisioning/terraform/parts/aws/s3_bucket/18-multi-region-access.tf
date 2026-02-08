# 18. Multi-Region Access Point S3 Bucket
# Unified configuration for routing traffic to the closest regional bucket.

resource "aws_s3_bucket" "regional_bucket_a" {
  bucket = "mrap-bucket-us-east-1-${random_id.bucket_id.hex}"
}

resource "aws_s3_bucket" "regional_bucket_b" {
  bucket = "mrap-bucket-us-west-2-${random_id.bucket_id.hex}"
}

# (Multi-region access points are advanced and require specific cross-region setup)
# Resource: aws_s3control_multi_region_access_point
