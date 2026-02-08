# 08. Lambda with CloudWatch Scheduled Event (Cron)
# running code on a recurring schedule (e.g., house cleaning).

resource "aws_lambda_function" "cron_lambda" {
  filename      = "cron.zip"
  function_name = "daily-cleanup-job"
  role          = var.lambda_role_arn
  handler       = "cleanup.handler"
  runtime       = "python3.9"
}

resource "aws_cloudwatch_event_rule" "every_day" {
  name                = "every-day-at-midnight"
  description         = "Fires every day at midnight"
  schedule_expression = "cron(0 0 * * ? *)"
}

resource "aws_cloudwatch_event_target" "check_every_day" {
  rule      = aws_cloudwatch_event_rule.every_day.name
  target_id = "lambda"
  arn       = aws_lambda_function.cron_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cron_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_day.arn
}
