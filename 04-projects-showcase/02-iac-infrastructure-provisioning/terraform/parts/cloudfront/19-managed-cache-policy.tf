# 19. CloudFront with Managed Caching Policy
# Using AWS-managed policies for common use cases (e.g., CachingOptimized).

resource "aws_cloudfront_distribution" "managed_policy_dist" {
  origin {
    domain_name = var.s3_bucket_domain_name
    origin_id   = "S3-Origin"
  }

  enabled = true

  default_cache_behavior {
    target_origin_id       = "S3-Origin"
    viewer_protocol_policy = "redirect-to-https"

    # CachingOptimized policy (Managed by AWS)
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
