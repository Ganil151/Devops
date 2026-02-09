# 13. Lambda with Destination
# routing the result of an asynchronous invocation.

resource "aws_lambda_function_event_invoke_config" "example" {
  function_name = aws_lambda_function.python_basic.function_name

  destination_config {
    on_failure {
      destination = var.failure_sns_topic_arn
    }
    on_success {
      destination = var.success_sqs_queue_arn
    }
  }
}
