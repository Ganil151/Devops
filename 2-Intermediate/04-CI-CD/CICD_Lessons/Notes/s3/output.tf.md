module/output.tf
```terraform
# Output the S3 Bucket Name

output "bucket_name" {

  value = aws_s3_bucket.project_register.bucket

}
```