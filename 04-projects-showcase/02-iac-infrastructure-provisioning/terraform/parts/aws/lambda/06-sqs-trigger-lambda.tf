# 06. Lambda with SQS Trigger
# Processing jobs from an asynchronous queue.

resource "aws_lambda_function" "sqs_worker" {
  filename      = "worker.zip"
  function_name = "sqs-queue-worker"
  role          = var.lambda_role_arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
}

resource "aws_lambda_event_source_mapping" "sqs_mapping" {
  event_source_arn = var.sqs_queue_arn
  function_name    = aws_lambda_function.sqs_worker.arn
  batch_size       = 10
}
