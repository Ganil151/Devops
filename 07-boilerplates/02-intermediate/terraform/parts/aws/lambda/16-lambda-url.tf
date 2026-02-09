# 16. Lambda with URL (Functional URL)
# A simple way to expose a Lambda function via HTTP without API Gateway.

resource "aws_lambda_function_url" "example" {
  function_name      = aws_lambda_function.python_basic.function_name
  authorization_type = "NONE" # Public access (use IAM for private)
  
  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
}

output "lambda_url" {
  value = aws_lambda_function_url.example.function_url
}
