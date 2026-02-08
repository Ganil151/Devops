# 02. Node.js Lambda
# Javascript-based function deployment.

resource "aws_lambda_function" "node_basic" {
  filename      = "node_app.zip"
  function_name = "basic-node-app"
  role          = var.lambda_role_arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  source_code_hash = filebase64sha256("node_app.zip")
}
