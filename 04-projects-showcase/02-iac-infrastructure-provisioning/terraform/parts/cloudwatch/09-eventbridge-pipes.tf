# 09. CloudWatch EvendBridge Pipe
# connecting an SQS source to a Lambda target with optional filtering and enrichment.

resource "aws_pipes_pipe" "example" {
  name     = "sqs-to-lambda-pipe"
  role_arn = var.pipe_role_arn
  source   = var.sqs_queue_arn
  target   = var.lambda_function_arn

  source_parameters {
    sqs_queue_parameters {
      batch_size = 10
    }
  }
}
