# 09. Lambda with Layers
# Shared code or dependencies used across multiple functions.

resource "aws_lambda_layer_version" "example_layer" {
  filename   = "layer_content.zip"
  layer_name = "common-utilities"

  compatible_runtimes = ["python3.9"]
}

resource "aws_lambda_function" "with_layer" {
  filename      = "app.zip"
  function_name = "app-using-shared-layer"
  role          = var.lambda_role_arn
  handler       = "index.handler"
  runtime       = "python3.9"

  layers = [aws_lambda_layer_version.example_layer.arn]
}
