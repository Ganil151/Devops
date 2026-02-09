# 11. Lambda Alias and Versions
# managing different environments (Dev, Prod) within the same function.

resource "aws_lambda_function" "versioned_app" {
  filename      = "app.zip"
  function_name = "versioned-application"
  role          = var.lambda_role_arn
  handler       = "index.handler"
  runtime       = "python3.9"
  publish       = true # Required to create new versions
}

resource "aws_lambda_alias" "prod_alias" {
  name             = "PROD"
  description      = "Production Alias"
  function_name    = aws_lambda_function.versioned_app.function_name
  function_version = "1"
}
