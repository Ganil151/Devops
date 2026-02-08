# 13. CloudFront Custom Error Pages
# providing branded error pages (404, 500) for a better user experience.

resource "aws_cloudfront_distribution" "custom_errors" {
  origin {
    domain_name = var.s3_bucket_domain_name
    origin_id   = "S3-Origin"
  }

  enabled = true

  default_cache_behavior {
    target_origin_id       = "S3-Origin"
    viewer_protocol_policy = "redirect-to-https"
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/error-404.html"
    error_caching_min_ttl = 300
  }

  custom_error_response {
    error_code            = 500
    response_code         = 500
    response_page_path    = "/maintenance.html"
    error_caching_min_ttl = 300
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
