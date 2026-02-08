# 07. Private S3 Bucket (Block Public Access)
# Strictly prevents any public access to the bucket and its objects.

resource "aws_s3_bucket" "private" {
  bucket = "highly-private-bucket-${random_id.bucket_id.hex}"
}

resource "aws_s3_bucket_public_access_block" "private" {
  bucket = aws_s3_bucket.private.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
