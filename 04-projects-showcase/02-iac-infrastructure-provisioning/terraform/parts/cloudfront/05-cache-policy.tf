# 05. CloudFront Cache Policy
# creating optimized caching rules for different types of content.

resource "aws_cloudfront_cache_policy" "dynamic_content" {
  name        = "dynamic-content-policy"
  comment     = "Policy for dynamic content with query strings"
  default_ttl = 60
  max_ttl     = 300
  min_ttl     = 1

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "all"
    }
    headers_config {
      header_behavior = "whitelist"
      headers {
        items = ["Authorization", "Host"]
      }
    }
    query_strings_config {
      query_string_behavior = "all"
    }
  }
}
