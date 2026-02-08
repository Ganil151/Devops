# 03. Lambda with Environment Variables
# Injecting configuration values into the function runtime.

resource "aws_lambda_function" "env_vars" {
  filename      = "app.zip"
  function_name = "app-with-configs"
  role          = var.lambda_role_arn
  handler       = "index.handler"
  runtime       = "python3.9"

  environment {
    variables = {
      DB_HOST = "mydb.cluster.internal"
      LOG_LEVEL = "DEBUG"
      APP_ENV   = "production"
    }
  }
}
