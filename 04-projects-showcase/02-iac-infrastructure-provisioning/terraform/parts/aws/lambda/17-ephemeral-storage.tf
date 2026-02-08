# 17. Lambda with Ephemeral Storage (/tmp)
# increasing the disk space available to the function (up to 10GB).

resource "aws_lambda_function" "high_storage" {
  filename      = "app.zip"
  function_name = "image-processor-large-tmp"
  role          = var.lambda_role_arn
  handler       = "index.handler"
  runtime       = "python3.9"

  ephemeral_storage {
    size = 1024 # 1 GB (Default is 512 MB)
  }
}
