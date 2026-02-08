# 11. ALB Target Group (Lambda)
# Use a serverless function as a load balancer target.

resource "aws_lb_target_group" "lambda_target" {
  name        = "lambda-tg"
  target_type = "lambda"
}

resource "aws_lb_target_group_attachment" "lambda_attach" {
  target_group_arn = aws_lb_target_group.lambda_target.arn
  target_id        = var.lambda_arn
}
