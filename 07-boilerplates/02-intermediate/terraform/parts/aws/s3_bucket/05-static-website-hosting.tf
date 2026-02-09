# 05. Static Website Hosting S3 Bucket
# Configures the bucket to host a static website.

resource "aws_s3_bucket" "website" {
  bucket = "static-website-${random_id.bucket_id.hex}"
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}
