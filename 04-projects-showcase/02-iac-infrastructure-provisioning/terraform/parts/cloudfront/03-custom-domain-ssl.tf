# 03. CloudFront with Custom Domain and SSL (ACM)
# linking a branded domain name (e.g., cdn.example.com) with an SSL certificate.

resource "aws_cloudfront_distribution" "custom_domain" {
  aliases = ["cdn.example.com"]

  origin {
    domain_name = var.s3_bucket_domain_name
    origin_id   = "S3-Origin"
  }

  enabled = true

  default_cache_behavior {
    target_origin_id       = "S3-Origin"
    viewer_protocol_policy = "redirect-to-https"
    # ... other behavior settings
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method        = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
# (Note: ACM certificate must be in us-east-1 for CloudFront)
