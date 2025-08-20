resource "aws_s3_bucket" "tf_s3_bucket" {
  bucket = "nodejs-bkt123"

  tags = {
    Name        = "NodeJs terraform bucket"
    Environment = "Dev"
  }
}

# Add Lifecycle Rules (Enable Versioning or Block Public Access)
resource "aws_s3_bucket_versioning" "tf_s3_bucket_versioning" {
  bucket = aws_s3_bucket.tf_s3_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}


# Upload files from the local directory to the S3 bucket
resource "aws_s3_object" "tf_s3_object" {
  bucket   = aws_s3_bucket.tf_s3_bucket.bucket
  for_each = fileset("../public/images", "**")
  key      = "images/${each.key}"
  source   = "../public/images/${each.key}"

}











# resource "aws_s3_object" "tf_s3_object" {
#   for_each = fileset("${path.module}/public/images", "**")
#   bucket = aws_s3_bucket.tf_s3_bucket.bucket
#   key    = "images/${each.key}"
#   source = abspath("${path.module}/public/images/${each.key}")

#   # The filemd5() function is available in Terraform 0.11.12 and late
#   etag   = filemd5(abspath("${path.module}/public/images/${each.key}"))
# }





# resource "aws_s3_object" "test_image" {
#   bucket = aws_s3_bucket.tf_s3_bucket.bucket
#   key    = "C:/Users/ganil/Documents/Web-Design-/Terraform/aws-intance/Youtube_Lessons/project/app/public/images/logo.png"
#   source = "C:/Users/ganil/Documents/Web-Design-/Terraform/aws-intance/Youtube_Lessons/project/app/public/images/logo.png"
# }



#   # The filemd5() function is available in Terraform 0.11.12 and later
#   # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
#   # etag = "${md5(file("path/to/file"))}"
#   etag = filemd5("path/to/file")
# }
