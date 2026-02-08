# 20. Minimalist S3 Bucket
# The absolute barebones bucket configuration.

resource "aws_s3_bucket" "minimal" {
  bucket = "minimal-poc-bucket-${random_id.bucket_id.hex}"
}
