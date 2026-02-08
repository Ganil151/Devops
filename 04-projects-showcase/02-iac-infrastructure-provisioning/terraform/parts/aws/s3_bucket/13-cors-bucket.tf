# 13. S3 Bucket with CORS Configuration
# Allows web applications in different domains to access resources in this bucket.

resource "aws_s3_bucket" "cors_bucket" {
  bucket = "webapp-assets-bucket-${random_id.bucket_id.hex}"
}

resource "aws_s3_bucket_cors_configuration" "cors" {
  bucket = aws_s3_bucket.cors_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET"]
    allowed_origins = ["https://s3-website-test.hashicorp.com"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}
