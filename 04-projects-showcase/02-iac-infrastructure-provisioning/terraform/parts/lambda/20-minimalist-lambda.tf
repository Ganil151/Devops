# 20. Minimalist Lambda
# The absolute barebones function definition.

resource "aws_lambda_function" "minimal" {
  filename      = "app.zip"
  function_name = "baseline-lambda"
  role          = var.lambda_role_arn
  handler       = "index.handler"
  runtime       = "python3.9"
}
