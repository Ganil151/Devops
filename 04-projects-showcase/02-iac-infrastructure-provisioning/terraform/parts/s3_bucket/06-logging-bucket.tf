# 06. Logging Destination S3 Bucket
# Used to store server access logs from other buckets.

resource "aws_s3_bucket" "log_bucket" {
  bucket = "logs-destination-${random_id.bucket_id.hex}"
}

resource "aws_s3_bucket_acl" "log_bucket_acl" {
  bucket = aws_s3_bucket.log_bucket.id
  acl    = "log-delivery-write"
}
