# 07. IAM Role for RDS
# Allowing RDS to access other AWS services (e.g., S3 for backups).

resource "aws_iam_role" "rds_access_role" {
  name = "rds_s3_integration_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      },
    ]
  })
}
# (Policies like AmazonRDSDirectoryServiceAccess can be attached here)
