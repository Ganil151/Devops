# 14. S3 Bucket with Transfer Acceleration
# Enables fast, easy, and secure transfers of files over long distances.

resource "aws_s3_bucket" "accelerated" {
  bucket = "fast-transfer-bucket-${random_id.bucket_id.hex}"
}

resource "aws_s3_accelerate_configuration" "accelerated" {
  bucket = aws_s3_bucket.accelerated.id
  status = "Enabled"
}
