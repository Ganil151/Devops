# 04. Lambda in a VPC
# Allowing the function to access private resources like RDS or ElastiCache.

resource "aws_lambda_function" "vpc_lambda" {
  filename      = "app.zip"
  function_name = "private-vpc-function"
  role          = var.lambda_role_arn
  handler       = "index.handler"
  runtime       = "python3.9"

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.security_group_id]
  }

  # Note: Lambda requires 'ec2:CreateNetworkInterface' etc. permissions.
}
