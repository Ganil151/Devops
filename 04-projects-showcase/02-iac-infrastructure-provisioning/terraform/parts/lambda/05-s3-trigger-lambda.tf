# 05. Lambda with S3 Trigger
# Automatically run code when an object is uploaded to a bucket.

resource "aws_lambda_function" "s3_processor" {
  filename      = "processor.zip"
  function_name = "s3-file-processor"
  role          = var.lambda_role_arn
  handler       = "main.process"
  runtime       = "python3.9"
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.bucket_arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.bucket_id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "uploads/"
    filter_suffix       = ".json"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}
