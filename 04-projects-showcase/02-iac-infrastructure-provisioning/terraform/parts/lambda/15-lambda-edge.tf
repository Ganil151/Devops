# 15. Lambda with Edge (CloudFront)
# running code closer to users to minimize latency.

resource "aws_lambda_function" "edge_lambda" {
  filename      = "edge_app.zip"
  function_name = "cloudfront-edge-function"
  role          = var.lambda_role_arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  publish       = true # Required for Edge functions
}

# (The function would be associated with a CloudFront Cache Behavior)
