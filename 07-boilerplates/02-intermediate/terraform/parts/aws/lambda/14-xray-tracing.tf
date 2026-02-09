# 14. Lambda with X-Ray Tracing
# Enabling distributed tracing to analyze and debug performance.

resource "aws_lambda_function" "traced_lambda" {
  filename      = "app.zip"
  function_name = "xray-traced-app"
  role          = var.lambda_role_arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  tracing_config {
    mode = "Active"
  }
}
