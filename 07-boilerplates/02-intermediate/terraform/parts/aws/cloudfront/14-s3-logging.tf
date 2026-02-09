# 14. CloudFront with S3 Logging
# Archiving CloudFront access logs to an S3 bucket for analysis.

resource "aws_cloudfront_distribution" "logged_dist" {
  origin {
    domain_name = var.s3_bucket_domain_name
    origin_id   = "S3-Origin"
  }

  enabled = true

  logging_config {
    include_cookies = false
    bucket          = var.logs_bucket_domain_name
    prefix          = "cloudfront-logs/"
  }

  default_cache_behavior {
    target_origin_id       = "S3-Origin"
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
