# 20. Minimalist IAM Policy
# The baseline configuration for a custom policy.

resource "aws_iam_policy" "minimal" {
  name   = "baseline-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:GetCallerIdentity", Effect = "Allow", Resource = "*" }]
  })
}
