# S3 Bucket for DevOps Project
resource "aws_s3_bucket" "project_register" {
  bucket = "${var.project_name}-register-${random_string.bucket_suffix.result}"
  
  tags = merge({
    Name        = "${var.project_name}-register"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }, var.tags)
}

# Random string for unique bucket naming
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "versioning" {
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.project_register.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  count  = var.enable_encryption ? 1 : 0
  bucket = aws_s3_bucket.project_register.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "state_bucket_block" {
  bucket = aws_s3_bucket.project_register.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Lifecycle Configuration
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  count  = var.lifecycle_enabled ? 1 : 0
  bucket = aws_s3_bucket.project_register.id
  
  rule {
    id     = "transition_to_ia"
    status = "Enabled"
    
    transition {
      days          = var.transition_to_ia_days
      storage_class = "STANDARD_IA"
    }
    
    transition {
      days          = var.transition_to_glacier_days
      storage_class = "GLACIER"
    }
    
    transition {
      days          = var.transition_to_deep_archive_days
      storage_class = "DEEP_ARCHIVE"
    }
    
    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_expiration_days
    }
  }
}

# IAM Role for EC2/Terraform
resource "aws_iam_role" "terraform_role" {
  name = "${var.project_name}-terraform-role"
  
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
  
  tags = merge({
    Name    = "${var.project_name}-terraform-role"
    Project = var.project_name
  }, var.tags)
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "terraform_profile" {
  name = "${var.project_name}-terraform-profile"
  role = aws_iam_role.terraform_role.name
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
          "s3:ListBucket",
          "s3:GetBucketVersioning",
          "s3:PutBucketVersioning"
        ]
        Resource = [
          aws_s3_bucket.project_register.arn,
          "${aws_s3_bucket.project_register.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole",
          "iam:GetRole",
          "iam:ListRoles"
        ]
        Resource = aws_iam_role.terraform_role.arn
      }
    ]
  })
}