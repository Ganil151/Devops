# 02. CloudFront Origin Access Control (OAC)
# The modern way to secure S3 origins (replaces Legacy OAIs).

resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "s3-oac"
  description                       = "Origin Access Control for S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
