# S3 Bucket
resource "aws_s3_bucket" "project_register" {
  bucket = "${var.project_name}-bucket"

  tags = {
    Name    = "${var.project_name}-bucket"
    Project = var.project_name
  }
}

# Enable Versioning
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.project_register.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Block Public Access
resource "aws_s3_bucket_public_access_block" "state_bucket_block" {
  bucket = aws_s3_bucket.project_register.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# IAM Role for EC2/Terraform
resource "aws_iam_role" "terraform_role" {
  name = "terraform-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com" # EC2 will assume this role
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Role Policy for S3 Access
resource "aws_iam_role_policy" "s3_policy" {
  role = aws_iam_role.terraform_role.name

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
          aws_s3_bucket.project_register.arn,
          "${aws_s3_bucket.project_register.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = aws_iam_role.terraform_role.arn
      }
    ]
  })
}


