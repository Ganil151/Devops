# 14. IAM Service-Linked Role
# Automatic roles managed by AWS for specific services (e.g., Auto Scaling).

resource "aws_iam_service_linked_role" "autoscaling" {
  aws_service_name = "autoscaling.amazonaws.com"
}
