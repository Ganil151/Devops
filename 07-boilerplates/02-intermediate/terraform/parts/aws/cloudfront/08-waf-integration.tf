# 08. CloudFront with WAF Integration
# Adaching a Web Application Firewall to the distribution to block malicious traffic.

resource "aws_cloudfront_distribution" "waf_protected" {
  origin {
    domain_name = var.s3_bucket_domain_name
    origin_id   = "S3-Origin"
  }

  enabled = true
  web_acl_id = var.waf_web_acl_id # Global WAF (us-east-1)

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
