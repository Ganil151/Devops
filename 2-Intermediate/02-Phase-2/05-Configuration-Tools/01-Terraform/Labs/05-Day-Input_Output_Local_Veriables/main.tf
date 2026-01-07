
# create s3 bucket
resource "aws_s3_bucket" "demo_bucket" {
  bucket = "gsmash-demo-bucket-name-123456"
  
  tags = {
    Name        = "MyBucket 0.3.0"
    Environment = "Dev"
  }
}