# 11. VPC with Flow Logs
# Capture IP traffic information for monitoring and auditing.

resource "aws_vpc" "logged_vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "Audited-VPC"
  }
}

resource "aws_flow_log" "vpc_logs" {
  iam_role_arn    = aws_iam_role.flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_logs.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.logged_vpc.id
}

resource "aws_cloudwatch_log_group" "vpc_logs" {
  name              = "VPC-Traffic-Logs"
  retention_in_days = 7
}

resource "aws_iam_role" "flow_log_role" {
  name = "vpc-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      },
    ]
  })
}
# (Note: IAM policies for writing to CloudWatch would also be needed here)
