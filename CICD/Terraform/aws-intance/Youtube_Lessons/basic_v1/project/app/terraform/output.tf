output "upload_files" {
  value = [for obj in aws_s3_object.tf_s3_object : obj.key]
}