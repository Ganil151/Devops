# 01. Basic Python Lambda
# Simple function with an archive-based deployment.

resource "aws_lambda_function" "python_basic" {
  filename      = "lambda_function_payload.zip"
  function_name = "basic-python-app"
  role          = var.lambda_role_arn # See parts/iam/06-iam-role-lambda.tf
  handler       = "index.handler"
  runtime       = "python3.9"

  source_code_hash = filebase64sha256("lambda_function_payload.zip")
}
