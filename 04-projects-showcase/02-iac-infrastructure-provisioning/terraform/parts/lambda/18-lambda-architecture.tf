# 18. Lambda with Architecture (ARM64/x86_64)
# optimizing for cost and performance using different CPU architectures.

resource "aws_lambda_function" "arm_lambda" {
  filename      = "app.zip"
  function_name = "graviton-powered-lambda"
  role          = var.lambda_role_arn
  handler       = "index.handler"
  runtime       = "python3.9"

  architectures = ["arm64"] # Graviton2
}
