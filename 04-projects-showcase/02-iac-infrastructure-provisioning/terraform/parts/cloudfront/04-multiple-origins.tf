# 04. CloudFront with Multiple Origins (S3 + ALB)
# serving static files from S3 and dynamic requests from an Application Load Balancer.

resource "aws_cloudfront_distribution" "multi_origin" {
  origin {
    domain_name = var.s3_bucket_domain_name
    origin_id   = "S3-Static"
  }

  origin {
    domain_name = var.alb_domain_name
    origin_id   = "ALB-Dynamic"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled = true

  # Default to S3
  default_cache_behavior {
    target_origin_id       = "S3-Static"
    viewer_protocol_policy = "redirect-to-https"
  }

  # Route /api/* to ALB
  ordered_cache_behavior {
    path_pattern     = "/api/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "ALB-Dynamic"

    forwarded_values {
      query_string = true
      headers      = ["*"]
      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }
}
