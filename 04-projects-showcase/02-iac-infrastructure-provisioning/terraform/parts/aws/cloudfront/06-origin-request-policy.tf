# 06. CloudFront Origin Request Policy
# controlling which headers and query strings are forwarded to the origin (without affecting cache key).

resource "aws_cloudfront_origin_request_policy" "api_forwarding" {
  name    = "api-request-policy"
  comment = "Forwards all headers to the API origin"

  cookies_config {
    cookie_behavior = "all"
  }
  headers_config {
    header_behavior = "allViewer"
  }
  query_strings_config {
    query_string_behavior = "all"
  }
}
