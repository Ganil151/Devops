# 12. Lambda with Provisioned Concurrency
# Eliminates "cold starts" by keeping instances ready.

resource "aws_lambda_provisioned_concurrency_config" "example" {
  function_name                     = aws_lambda_alias.prod_alias.function_name
  provisioned_concurrent_executions = 5
  qualifier                         = aws_lambda_alias.prod_alias.name
}
