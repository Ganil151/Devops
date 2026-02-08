# 15. CloudFront Price Class Configuration
# Controlling costs by limiting the edge locations used for the distribution.

resource "aws_cloudfront_distribution" "cheap_dist" {
  origin {
    domain_name = var.s3_bucket_domain_name
    origin_id   = "S3-Origin"
  }

  enabled = true

  # PriceClass_100: US, Canada, Europe only (Cheapest)
  # PriceClass_200: 100 + Asia, Africa, South America
  # PriceClass_All: Global (Most expensive)
  price_class = "PriceClass_100"

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
