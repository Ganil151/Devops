# Output Values for S3 Bucket Module

output "bucket_id" {
  description = "The ID of the S3 bucket"
  value       = aws_s3_bucket.project_register.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.project_register.arn
}

output "bucket_domain_name" {
  description = "The bucket domain name"
  value       = aws_s3_bucket.project_register.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "The bucket regional domain name"
  value       = aws_s3_bucket.project_register.bucket_regional_domain_name
}

output "bucket_hosted_zone_id" {
  description = "The Route 53 Hosted Zone ID for this bucket's region"
  value       = aws_s3_bucket.project_register.hosted_zone_id
}

output "bucket_region" {
  description = "The AWS region this bucket resides in"
  value       = aws_s3_bucket.project_register.region
}

output "iam_role_arn" {
  description = "The ARN of the IAM role for S3 access"
  value       = aws_iam_role.terraform_role.arn
}

output "iam_role_name" {
  description = "The name of the IAM role for S3 access"
  value       = aws_iam_role.terraform_role.name
}

output "iam_instance_profile_arn" {
  description = "The ARN of the IAM instance profile"
  value       = aws_iam_instance_profile.terraform_profile.arn
}

output "iam_instance_profile_name" {
  description = "The name of the IAM instance profile"
  value       = aws_iam_instance_profile.terraform_profile.name
}