# 11. CloudFront Signed URLs
# restriction access to content using pre-signed URLs (Private Content).

resource "aws_cloudfront_public_key" "example" {
  comment     = "example public key"
  encoded_key = file("public_key.pem")
  name        = "example-key"
}

resource "aws_cloudfront_key_group" "example" {
  comment = "example key group"
  items   = [aws_cloudfront_public_key.example.id]
  name    = "example-key-group"
}

resource "aws_cloudfront_distribution" "private_dist" {
  origin {
    domain_name = var.s3_bucket_domain_name
    origin_id   = "S3-Private"
  }

  enabled = true

  default_cache_behavior {
    target_origin_id       = "S3-Private"
    viewer_protocol_policy = "redirect-to-https"
    trusted_key_groups     = [aws_cloudfront_key_group.example.id]
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
