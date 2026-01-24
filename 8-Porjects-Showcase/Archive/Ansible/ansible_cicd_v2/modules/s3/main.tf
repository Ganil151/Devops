resource "aws_s3_bucket" "ansible_register" {
  bucket = var.bucket_name

  tags = {
    Name = var.bucket_name
  }
}

resource "aws_s3_bucket_public_access_block" "state_bucket_block" {
  bucket = aws_s3_bucket.ansible_register.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role" "terraform_role" {
  name = "terraform_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "terraform_role_policy" {
  name = "terraform_role_policy"
  role = aws_iam_role.terraform_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.ansible_register.arn,
          "${aws_s3_bucket.ansible_register.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole",
          "s3:ListAllMyBuckets"
        ]
        Resource = aws_iam_role.terraform_role.arn
      }
    ]
  })
}
